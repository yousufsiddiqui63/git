#!/bin/sh

test_description='handling of common mistakes people may make with submodules'

TEST_PASSES_SANITIZE_LEAK=true
. ./test-lib.sh

test_expect_success 'create embedded repository' '
	git init embed &&
	test_commit -C embed one
'

test_expect_success 'git-add on embedded repository dies' '
	test_must_fail git add embed 2>stderr &&
	test_i18ngrep fatal stderr
'

test_expect_success '--allow-embedded-repo adds embedded repository and suppresses error message' '
	test_when_finished "git rm --cached -f embed" &&
	git add --allow-embedded-repo embed 2>stderr &&
	test_i18ngrep ! fatal stderr
'

test_expect_success '--no-warn-embedded-repo dies and suppresses advice' '
	test_must_fail git add --no-warn-embedded-repo embed 2>stderr &&
	test_i18ngrep ! hint stderr &&
	test_i18ngrep fatal stderr
'

test_expect_success 'no error message when updating entry' '
	test_when_finished "git rm --cached -f embed" &&
	git add --allow-embedded-repo embed &&
	git -C embed commit --allow-empty -m two &&
	git add embed 2>stderr &&
	test_i18ngrep ! fatal stderr
'

test_expect_success 'submodule add neither fails nor issues error message' '
	test_when_finished "git rm -rf submodule .gitmodules" &&
	git -c protocol.file.allow=always \
		submodule add ./embed submodule 2>stderr &&
	test_i18ngrep ! fatal stderr
'

test_done
