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
	fprintf(stderr, "sigpthread -t threads\n"
	    "    -k kill        thread to kill, else process\n"
	    "    -t threads     number of threads to run\n"
	);
	exit(1);
}

int tmax;
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

	while ((ch = getopt(argc, argv, "k:t:")) != -1) {
		switch (ch) {
		case 'k':
			tkill = strtonum(optarg, 0, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "thread to kill is %s: %s",
				    errstr, optarg);
			break;
		case 't':
			tmax = strtonum(optarg, 1, INT_MAX, &errstr);
			if (errstr != NULL)
				errx(1, "number of threads is %s: %s",
				    errstr, optarg);
			break;
		default:
			usage();
		}
	}
	argc -= optind;
	argv += optind;
	if (tmax == 0)
		errx(1, "number of threads required");
	if (tkill >= tmax)
		errx(1, "thread to kill greater than number of threads");

	/* Make sure that we do not hang forever. */
	ret = alarm(10);
	if (ret == -1)
		err(1, "alarm");

	memset(&act, 0, sizeof(act));
	act.sa_handler = handler;
	if (sigaction(SIGUSR1, &act, NULL) == -1)
		err(1, "sigaction");

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

	if (tkill < 0) {
		if (raise(SIGUSR1) == -1)
			err(1, "raise");
	} else {
		errno = pthread_kill(threads[tkill], SIGUSR1);
		if (errno)
			err(1, "pthread_kill %d", tnum);
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
		if (signaled[tnum])
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
			signaled[tnum] = 1;
	}
}

void *
runner(void *arg)
{
	int tnum = (int)arg;

	printf("run %d\n", tnum);
	return (void *)0;
}
