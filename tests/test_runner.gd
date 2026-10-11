extends SceneTree

const TestSaveManager = preload("res://tests/test_save_manager.gd")
const TestMobBehaviors = preload("res://tests/test_mob_behaviors.gd")
const TestPlayer = preload("res://tests/test_player.gd")
const TestGameplayIntegration = preload("res://tests/test_gameplay_integration.gd")

var passed: int = 0
var failed: int = 0


func _initialize() -> void:
	print("==========================================")
	print("DODGE THE CREEPS - AUTOMATED TEST SUITE")
	print("==========================================")
	await run_all_test_suites()
	print("==========================================")
	print("TEST SUITE RESULTS: %d PASSED, %d FAILED" % [passed, failed])
	print("==========================================")
	quit(1 if failed > 0 else 0)


func assert_eq(actual, expected, label: String) -> void:
	if actual == expected:
		passed += 1
		print("  [PASS] %s" % label)
	else:
		failed += 1
		push_error("  [FAIL] %s: expected %s, got %s" % [label, expected, actual])


func assert_true(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("  [PASS] %s" % label)
	else:
		failed += 1
		push_error("  [FAIL] %s: condition was false" % label)


func run_all_test_suites() -> void:
	await process_frame
	
	TestSaveManager.run(self)
	await process_frame
	
	TestMobBehaviors.run(self)
	await process_frame
	
	await TestPlayer.run(self)
	await process_frame
	
	TestGameplayIntegration.run(self)
	await process_frame
