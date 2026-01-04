## PostgreSQL Session Management Feature
## Targets: pg/session/kill/%, pg/session/kill-idle, pg/session/cancel/%
ifndef __MB_PG_FEATURE_SESSION__
__MB_PG_FEATURE_SESSION__ := 1

ifndef __MB_TEST_DISCOVERY__

pg/session/kill/%: ## Kill session by PID (make pg/session/kill/12345)
	$(call mb_printf_info,Terminating session with PID: $*)
	$(call pg_invoke,$(pg_psql) -d postgres -Atc "SELECT pg_terminate_backend($*);")

pg/session/kill-idle: ## Kill idle sessions older than pg_idle_timeout minutes (default: 30)
	$(call mb_printf_info,Killing idle sessions older than $(pg_idle_timeout) minutes)
	$(call pg_invoke,$(pg_psql) -d postgres -c \
	"SELECT pg_terminate_backend(pid)$(mb_comma) usename$(mb_comma) datname$(mb_comma) state$(mb_comma) state_change \
	FROM pg_stat_activity \
	WHERE pid <> pg_backend_pid() \
	AND state IN ('idle'$(mb_comma) 'idle in transaction'$(mb_comma) 'idle in transaction (aborted)') \
	AND state_change < now() - interval '$(pg_idle_timeout) minutes';")

pg/session/cancel/%: ## Cancel query (not session) by PID - connection stays open
	$(call mb_printf_info,Cancelling query for PID: $*)
	$(call pg_invoke,$(pg_psql) -d postgres -Atc "SELECT pg_cancel_backend($*);")

endif # __MB_TEST_DISCOVERY__

endif # __MB_PG_FEATURE_SESSION__
