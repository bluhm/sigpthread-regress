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

REGRESS_TARGETS +=	run-thread-3-unblock-$u-sleep-main
run-thread-3-unblock-$u-sleep-main:
	@echo '\n======== $@ ========'
	./sigpthread -s -t 3 -u $u >out
	grep 'signal $u' out

REGRESS_TARGETS +=	run-thread-3-unblock-$u-sleep-thread
run-thread-3-unblock-$u-sleep-thread:
	@echo '\n======== $@ ========'
	./sigpthread -S -t 3 -u $u >out
	grep 'signal $u' out
.endfor

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
