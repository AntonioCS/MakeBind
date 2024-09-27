
test/core/util/mb_os_detection:
	$(call mb_os_detection)
	$(if $(and $(value OS),$(filter Windows_NT,$(OS))),
		$(call mb_assert,$(mb_os_is_windows),mb_os_detection failed for windows),
		$(eval uname := $(shell uname -s))
		$(if $(filter Linux,$(uname)),
			$(call mb_assert,$(mb_os_is_linux),mb_os_detection failed for linux),
			$(if $(filter Darwin,$(uname)),
				$(call mb_assert,$(mb_os_is_osx),mb_os_detection failed for mac),
			)
		)
	)


test/core/util/mb_os_call:
	$(call mb_os_detection)
	$(eval value := $(call mb_os_call,echo Windows,echo Linux,echo Mac))
	$(if $(and $(value OS),$(filter Windows_NT,$(OS))),
		$(call mb_assert_eq,$(value),Windows),
		$(eval uname := $(shell uname -s))
		$(if $(filter Linux,$(uname)),
			$(call mb_assert_eq,$(value),Linux),
			$(if $(filter Darwin,$(uname)),
				$(call mb_assert_eq,$(value),Mac),
			)
		)
	)