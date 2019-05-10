# $OpenBSD$

PROG =		sigpthread
WARNINGS =	yes
LDADD =		-lpthread
DPADD =		${LIBPTHREAD}

run-regress-sigpthread:
	./sigpthread -t 2

.include <bsd.regress.mk>
