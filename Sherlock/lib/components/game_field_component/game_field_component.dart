import 'dart:async';
import 'package:angular2/angular2.dart';
import 'package:sherlock/components/game_field_component/board_cell_component/horizontal_clue_component/horizontal_clue_component.dart';
import 'package:sherlock/components/game_field_component/board_cell_component/vertical_clue_component/vertical_clue_component.dart';
import 'package:sherlock/components/game_field_component/board_component/board_component.dart';
import 'package:sherlock/model/clues/generic_clue.dart';
import 'package:sherlock/model/clues/one_should_be_before_other_clue.dart';
import 'package:sherlock/model/clues/three_adjacent_clue.dart';
import 'package:sherlock/model/clues/two_adjacent_clue.dart';
import 'package:sherlock/model/clues/two_in_same_column_clue.dart';
import 'package:sherlock/model/clues/two_not_adjacent_clue.dart';
import 'package:sherlock/model/clues/two_not_in_same_column_clue.dart';
import 'package:sherlock/model/clues/two_with_not_third_at_center_clue.dart';
import 'package:sherlock/services/game_service.dart';

@Component(
    selector: 'game-field',
    styleUrls: const ['game_field_component.css'],
    templateUrl: 'game_field_component.html',
    directives: const [
      BoardComponent,
      VerticalClueComponent,
      HorizontalClueComponent
    ]
)
class GameFieldComponent {

  final List<int> columns = [0, 1, 2];
  final List<int> rows = [0, 1, 2, 3, 4, 5, 6];

  static const String UNDO_TEXT_NORMAL = "Undo to Last Correct";
  static const String UNDO_TEXT_OK = "You're still doing OK!";

  //DateTime undoButtonTextChangeTime = new DateTime.now();
  Timer timer;

  final GameService _gameService;

  String _undoText = UNDO_TEXT_NORMAL;

  String get undoButtonText => _undoText;

  String get difficultyString {
    if (_gameService.difficulty == 0) {
      return "Hard";
    }
    else if (_gameService.difficulty == 1) {
      return "Medium";
    }
    else {
      return "Easy";
    }
  }

  List<GenericClue> get verticalClues =>
      _gameService.currentPuzzle.ruleSet.where((GenericClue clue) =>
      clue is TwoInSameColumnClue || clue is TwoNotInSameColumnClue
      ).toList(growable: false);

  List<GenericClue> get horizontalClues =>
      _gameService.currentPuzzle.ruleSet.where((GenericClue clue) =>
      clue is OneShouldBeBeforeOtherClue
          || clue is ThreeAdjacentClue
          || clue is TwoAdjacentClue
          || clue is TwoNotAdjacentClue
          || clue is TwoWithNoThirdAtCenterClue
      ).toList(growable: false);

  GameFieldComponent(this._gameService);

  GenericClue getClue(int index) {
    if (horizontalClues.length > index) {
      return horizontalClues[index];
    }
    return null;
  }

  void restartGame() {
    _gameService.initRandomConfiguration();
  }

  void undo() {
    _gameService.undo();
  }

  void undoToLastKnownGood() {
    bool undoed = _gameService.undoToLastKnownGood();
    if (!undoed) {
      _undoText = UNDO_TEXT_OK;
      timer?.cancel();
      timer = new Timer(new Duration(seconds: 3), () => _undoText = UNDO_TEXT_NORMAL);
    }
  }

  void changeDifficulty() {
    _gameService.difficulty--;
    if (_gameService.difficulty < 0) {
      _gameService.difficulty = 2;
    }
    _gameService.initRandomConfiguration();
  }

  void changeUsage(GenericClue clue) {
    if (clue != null) {
      clue.used = !clue.used;
    }
  }

  bool isUsed(GenericClue clue) {
    return clue?.used?? false;
  }

}