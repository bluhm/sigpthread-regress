# $OpenBSD$

PROG =		sigpthread
WARNINGS =	yes
LDADD =		-lpthread
DPADD =		${LIBPTHREAD}


REGRESS_TARGETS +=	run-sigpthread
run-sigpthread:
	./sigpthread -t 3 -u 2

REGRESS_TARGETS +=	run-sleep-main
run-sleep-main:
	./sigpthread -s -t 3 -u 2

REGRESS_TARGETS +=	run-sleep-thread
run-sleep-thread:
	./sigpthread -S -t 3 -u 2

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
