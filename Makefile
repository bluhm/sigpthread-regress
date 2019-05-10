# $OpenBSD$

PROG =		sigpthread
WARNINGS =	yes
LDADD =		-lpthread
DPADD =		${LIBPTHREAD}

run-regress-sigpthread:
	./sigpthread -t 3 -k 1 -u 1

.include <bsd.regress.mk>
