# $OpenBSD$

PROG =		sigpthread
WARNINGS =	yes
LDADD =		-lpthread
DPADD =		${LIBPTHREAD}
CLEANFILES +=	out

.for u in 0 1 2
REGRESS_TARGETS +=	run-thread-3-unblock-$u
run-thread-3-unblock-$u:
	@echo '\n======== $@ ========'
	./sigpthread -t 3 -u $u >out
	grep 'signal $u' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-unblock-$u-sleep-main
run-thread-3-unblock-$u-sleep-main:
	@echo '\n======== $@ ========'
	./sigpthread -s -t 3 -u $u >out
	grep 'signal $u' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-unblock-$u-sleep-thread
run-thread-3-unblock-$u-sleep-thread:
	@echo '\n======== $@ ========'
	./sigpthread -S -t 3 -u $u >out
	grep 'signal $u' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-unblock-$u-sleep-unblock
run-thread-3-unblock-$u-sleep-unblock:
	@echo '\n======== $@ ========'
	./sigpthread -t 3 -U -u $u >out
	grep 'signal $u' out
	test `wc -l <out` = 1
.endfor

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
