/*	$OpenBSD$	*/
/*
 * Copyright (c) 2019 Alexander Bluhm <bluhm@openbsd.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <err.h>
#include <errno.h>
#include <limits.h>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void __dead usage(void);
void handler(int);
void *runner(void *);

void __dead
usage(void)
{
	fprintf(stderr, "sigpthread [-Ss] [-k kill] -t threads [-u unblock]\n"
	    "    -k kill        thread to kill, else process\n"
	    "    -t threads     number of threads to run\n"
	    "    -S             sleep in each thread before suspend\n"
	    "    -s             sleep in main before kill\n"
	    "    -u unblock     thread to unblock\n"
	);
	exit(1);
}

int tmax, tunblock = -1;
int sleepthread, sleepmain;
sigset_t set, oset;
pthread_t *threads;
volatile sig_atomic_t *signaled;

int
main(int argc, char *argv[])
{
	struct sigaction act;
	int ch, ret, tnum, tkill = -1;
	long arg;
	void *val;
	const char *errstr;

	while ((ch = getopt(argc, argv, "k:Sst:u:")) != -1) {
		switch (ch) {
		case 'k':
			tkill = strtonum(optarg, 0, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "thread to kill is %s: %s",
				    errstr, optarg);
			break;
		case 'S':
			sleepthread = 1;
			break;
		case 's':
			sleepmain = 1;
			break;
		case 't':
			tmax = strtonum(optarg, 1, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "number of threads is %s: %s",
				    errstr, optarg);
			break;
		case 'u':
			tunblock = strtonum(optarg, 0, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "thread to unblock is %s: %s",
				    errstr, optarg);
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (argc != 0)
		errx(1, "more arguments than expected");
	if (tmax == 0)
		errx(1, "number of threads required");
	if (tkill >= tmax)
		errx(1, "thread to kill greater than number of threads");
	if (tunblock >= tmax)
		errx(1, "thread to unblock greater than number of threads");

	/* Make sure that we do not hang forever. */
	ret = alarm(10);
	if (ret == -1)
		err(1, "alarm");

	if (sigemptyset(&set) == -1)
		err(1, "sigemptyset");
	if (sigaddset(&set, SIGUSR1) == -1)
		err(1, "sigaddset");
	if (sigaddset(&set, SIGUSR2) == -1)
		err(1, "sigaddset");
	/* Block both SIGUSR1 and SIGUSR2 with set. */
	if (sigprocmask(SIG_BLOCK, &set, &oset) == -1)
		err(1, "sigprocmask");
	/* Prepare to wait for SIGUSR1, but block SIGUSR2 with oset. */
	if (sigaddset(&oset, SIGUSR2) == -1)
		err(1, "sigaddset");

	memset(&act, 0, sizeof(act));
	act.sa_handler = handler;
	if (sigaction(SIGUSR1, &act, NULL) == -1)
		err(1, "sigaction SIGUSR1");
	if (sigaction(SIGUSR2, &act, NULL) == -1)
		err(1, "sigaction SIGUSR2");

	signaled = calloc(tmax, sizeof(*signaled));
	if (signaled == NULL)
		err(1, "calloc signaled");
	threads = calloc(tmax, sizeof(*threads));
	if (threads == NULL)
		err(1, "calloc threads");

	for (tnum = 1; tnum < tmax; tnum++) {
		arg = tnum;
		errno = pthread_create(&threads[tnum], NULL, runner,
		    (void *)arg);
		if (errno)
			err(1, "pthread_create %d", tnum);
	}
	/* Handle the main thread like thread 0. */
	threads[0] = pthread_self();

	/* Test what hapens if thread is running when killed. */
	if (sleepmain)
		sleep(1);

	/* All threads are still alive. */
	if (tkill < 0) {
		if (kill(getpid(), SIGUSR2) == -1)
			err(1, "kill SIGUSR2");
	} else {
		errno = pthread_kill(threads[tkill], SIGUSR2);
		if (errno)
			err(1, "pthread_kill %d SIGUSR2", tnum);
	}

	/* Sending SIGUSR1 means threads can continue and finish. */
	for (tnum = 0; tnum < tmax; tnum++) {
		errno = pthread_kill(threads[tnum], SIGUSR1);
		if (errno)
			err(1, "pthread_kill %d SIGUSR1", tnum);
	}

	val = runner(0);
	ret = (int)val;

	for (tnum = 1; tnum < tmax; tnum++) {
		errno = pthread_join(threads[tnum], &val);
		if (errno)
			err(1, "pthread_join %d", tnum);
		ret = (int)val;
		if (ret)
			errx(1, "pthread %d returned %d", tnum, ret);
	}
	free(threads);

	for (tnum = 0; tnum < tmax; tnum++) {
		if (signaled[tnum] == SIGUSR2)
			printf("signal %d\n", tnum);
	}
	free((void *)signaled);

	return 0;
}

void
handler(int sig)
{
	int tnum;
	pthread_t tid;

	tid = pthread_self();
	for (tnum = 0; tnum < tmax; tnum++) {
		if (tid == threads[tnum])
			signaled[tnum] = sig;
	}
}

void *
runner(void *arg)
{
	int tnum = (int)arg;

	/* Test what hapens if thread is running when killed. */
	if (sleepthread)
		sleep(1);

	/*
	 * Wait for SIGUSER1, continue to block SIGUSER2.
	 * The thread is keeps running until it gets SIGUSER1.
	 */
	if (sigsuspend(&oset) != -1 || errno != EINTR)
		err(1, "sigsuspend");
	if (tnum == tunblock) {
		/* Also unblock SIGUSER2, if this thread should get it. */
		if (pthread_sigmask(SIG_UNBLOCK, &set, NULL) == -1)
			err(1, "pthread_sigmask");
	}

	return (void *)0;
}
