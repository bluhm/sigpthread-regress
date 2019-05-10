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
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __dead usage(void);
void *runner(void *);

void __dead
usage(void)
{
	fprintf(stderr, "sigpthread [-t threads] ");
	exit(1);
}

int
main(int argc, char *argv[])
{
	int ch, tnum, tmax = 0;
	const char *errstr;
	pthread_t *threads;

	while ((ch = getopt(argc, argv, "t:")) != -1) {
		switch (ch) {
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

	threads = reallocarray(NULL, tmax, sizeof(*threads));
	for (tnum = 0; tnum < tmax; tnum++) {
		long arg = tnum;

		errno = pthread_create(&threads[tnum], NULL, runner,
		    (void *)arg);
		if (errno)
			err(1, "pthread_create %d", tnum);
	}

	for (tnum = 0; tnum < tmax; tnum++) {
		void *val;
		int ret;

		errno = pthread_join(threads[tnum], &val);
		if (errno)
			err(1, "pthread_join %d", tnum);
		ret = (int)val;
		if (ret)
			errx(1, "pthread %d returned %d", tnum, ret);
	}
	free(threads);

	return 0;
}

void *
runner(void *arg)
{
	int tnum = (int)arg;

	printf("%d\n", tnum);
	return (void *)0;
}
