import '../models/birth_context.dart';
import '../models/astro_snapshot.dart';
import '../models/culture_chart.dart';

abstract class CultureModule {
  CultureId get id;

  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot);
}
