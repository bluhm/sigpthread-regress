# $OpenBSD$

PROG =		sigpthread
WARNINGS =	yes
LDADD =		-lpthread
DPADD =		${LIBPTHREAD}
CLEANFILES +=	out

.for t in 0 1 2
REGRESS_TARGETS +=	run-block-thread-3-unblock-$t
run-block-thread-3-unblock-$t:
	@echo '\n======== $@ ========'
	./sigpthread -b -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-unblock-$t-sleep-main
run-block-thread-3-unblock-$t-sleep-main:
	@echo '\n======== $@ ========'
	./sigpthread -b -s -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-unblock-$t-sleep-thread
run-block-thread-3-unblock-$t-sleep-thread:
	@echo '\n======== $@ ========'
	./sigpthread -b -S -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-unblock-$t-sleep-unblock
run-block-thread-3-unblock-$t-sleep-unblock:
	@echo '\n======== $@ ========'
	./sigpthread -b -t 3 -U -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1
.endfor

REGRESS_TARGETS +=	run-block-thread-3
run-block-thread-3:
	@echo '\n======== $@ ========'
	./sigpthread -b -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main
run-block-thread-3-sleep-main:
	@echo '\n======== $@ ========'
	./sigpthread -b -s -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-thread
run-block-thread-3-sleep-thread:
	@echo '\n======== $@ ========'
	./sigpthread -b -S -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-unblock
run-block-thread-3-sleep-unblock:
	@echo '\n======== $@ ========'
	./sigpthread -b -t 3 -U >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

.for t in 0 1 2
REGRESS_TARGETS +=	run-block-thread-3-kill-$t
run-block-thread-3-kill-$t:
	@echo '\n======== $@ ========'
	./sigpthread -b -k $t -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main-kill-$t
run-block-thread-3-sleep-main-kill-$t:
	@echo '\n======== $@ ========'
	./sigpthread -b -k $t -s -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-thread-kill-$t
run-block-thread-3-sleep-thread-kill-$t:
	@echo '\n======== $@ ========'
	./sigpthread -b -k $t -S -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-unblock-kill-$t
run-block-thread-3-sleep-unblock-kill-$t:
	@echo '\n======== $@ ========'
	./sigpthread -b -k $t -t 3 -U >out
	grep 'signal $t' out
	test `wc -l <out` = 1
.endfor

REGRESS_TARGETS +=	run-thread-3
run-thread-3:
	@echo '\n======== $@ ========'
	./sigpthread -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-main
run-thread-3-sleep-main:
	@echo '\n======== $@ ========'
	./sigpthread -s -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-thread
run-thread-3-sleep-thread:
	@echo '\n======== $@ ========'
	./sigpthread -S -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-unblock
run-thread-3-sleep-unblock:
	@echo '\n======== $@ ========'
	./sigpthread -t 3 -U >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
