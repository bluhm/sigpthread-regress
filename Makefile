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
	# block signal
	# run 3 threads
	# kill process
	# suspend threads until signaled
	# unblock thread $t
	# handle signal
	./sigpthread -b -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main-unblock-$t
run-block-thread-3-sleep-main-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill process
	# unblock thread $t
	# handle signal
	./sigpthread -b -s -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-unblock-$t-sleep-thread
run-block-thread-3-sleep-thread-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill process
	# sleep in threads, signal should be pending when suspending
	# suspend threads until signaled
	# unblock thread $t
	# handle signal
	./sigpthread -b -S -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-unblock-unblock-$t
run-block-thread-3-sleep-unblock-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill process
	# suspend threads until signaled
	# sleep in thread $t, others should be exited when unblocking
	# unblock thread $t
	# handle signal
	./sigpthread -b -t 3 -U -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-kill-$k-unblock-$t
run-block-thread-3-kill-$k-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $t
	# suspend threads until signaled
	# unblock thread $t
	# handle signal
	./sigpthread -b -k $t -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main-kill-$k-unblock-$t
run-block-thread-3-sleep-main-kill-$k-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill thread $t
	# unblock thread $t
	# handle signal
	./sigpthread -b -k $t -s -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-kill-$k-sleep-thread-unblock-$t
run-block-thread-3-kill-$k-sleep-thread-unblock-$t:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $t
	# sleep in threads, signal should be pending when suspending
	# suspend threads until signaled
	# unblock thread $t
	# handle signal
	./sigpthread -b -k $t -S -t 3 -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-kill-$k-unblock-$t-sleep-unblock
run-block-thread-3-kill-$k-unblock-$t-sleep-unblock:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $k
	# suspend threads until signaled
	# sleep in thread $t, others should be exited when unblocking
	# unblock thread $t
	# handle signal
	./sigpthread -b -k $t -t 3 -U -u $t >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-kill-$k
run-block-thread-3-kill-$k:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $t
	# suspend threads until signaled
	# unblock all threads
	# handle signal
	./sigpthread -b -k $t -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main-kill-$k
run-block-thread-3-sleep-main-kill-$k:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill thread $t
	# unblock all threads
	# handle signal
	./sigpthread -b -k $t -s -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-kill-$k-sleep-thread
run-block-thread-3-kill-$k-sleep-thread:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $t
	# sleep in threads, signal should be pending when suspending
	# suspend threads until signaled
	# unblock all threads
	# handle signal
	./sigpthread -b -k $t -S -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

# XXX sleeping seems redundant
REGRESS_TARGETS +=	run-block-thread-3-kill-$k-sleep-unblock
run-block-thread-3-kill-$k-sleep-unblock:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill thread $k
	# suspend threads until signaled
	# sleep in all threads
	# unblock all threads
	# handle signal
	./sigpthread -b -k $t -t 3 -U >out
	grep 'signal $t' out
	test `wc -l <out` = 1

.endfor

REGRESS_TARGETS +=	run-block-thread-3
run-block-thread-3:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill process
	# suspend threads until signaled
	# unblock all threads
	# handle signal
	./sigpthread -b -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-main
run-block-thread-3-sleep-main:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill process
	# unblock all threads
	# handle signal
	./sigpthread -b -s -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-block-thread-3-sleep-thread
run-block-thread-3-sleep-thread:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill process
	# sleep in threads, signal should be pending when suspending
	# suspend threads until signaled
	# unblock all threads
	# handle signal
	./sigpthread -b -S -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

# XXX sleeping seems redundant
REGRESS_TARGETS +=	run-block-thread-3-sleep-unblock
run-block-thread-3-sleep-unblock:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# kill process
	# suspend threads until signaled
	# sleep in all threads
	# unblock all threads
	# handle signal
	./sigpthread -b -t 3 -U >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

.for t in 0 1 2

REGRESS_TARGETS +=	run-thread-3-kill-$k
run-thread-3-kill-$k:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill thread $t
	# handle signal
	# suspend threads until signaled
	./sigpthread -k $t -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-main-kill-$k
run-thread-3-sleep-main-kill-$k:
	@echo '\n======== $@ ========'
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill thread $t
	# handle signal
	./sigpthread -k $t -s -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-kill-$k-sleep-thread
run-thread-3-kill-$k-sleep-thread:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill thread $t
	# sleep in threads, signal should be received while sleeping
	# handle signal
	# suspend threads until signaled
	./sigpthread -k $t -S -t 3 >out
	grep 'signal $t' out
	test `wc -l <out` = 1

# XXX sleeping seems redundant
REGRESS_TARGETS +=	run-thread-3-kill-$k-sleep-unblock
run-thread-3-kill-$k-sleep-unblock:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill thread $k
	# handle signal
	# suspend threads until signaled
	# sleep in all threads
	./sigpthread -k $t -t 3 -U >out
	grep 'signal $t' out
	test `wc -l <out` = 1

.endfor

REGRESS_TARGETS +=	run-thread-3
run-thread-3:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill process
	# handle signal
	# suspend threads until signaled
	./sigpthread -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-main
run-thread-3-sleep-main:
	@echo '\n======== $@ ========'
	# block signal
	# run 3 threads
	# suspend threads until signaled
	# sleep in main thread, signal should be received while suspended
	# kill process
	# handle signal
	./sigpthread -s -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

REGRESS_TARGETS +=	run-thread-3-sleep-thread
run-thread-3-sleep-thread:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill process
	# sleep in threads, signal should be received while sleeping
	# handle signal
	# suspend threads until signaled
	./sigpthread -S -t 3 >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

# XXX sleeping seems redundant
REGRESS_TARGETS +=	run-thread-3-sleep-unblock
run-thread-3-sleep-unblock:
	@echo '\n======== $@ ========'
	# run 3 threads
	# kill process
	# handle signal
	# suspend threads until signaled
	# sleep in all threads
	./sigpthread -t 3 -U >out
	grep 'signal [0-2]' out
	test `wc -l <out` = 1

${REGRESS_TARGETS}: ${PROG}

.include <bsd.regress.mk>
