enum RiskLevel {
  low,
  medium,
  high,
}

String getRiskLabel(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return 'Низкий';
    case RiskLevel.medium:
      return 'Средний';
    case RiskLevel.high:
      return 'Высокий';
  }
}

String getRiskRecommendation(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return 'Сотрудник допущен к работе.';
    case RiskLevel.medium:
      return 'Рекомендуется повторная проверка.';
    case RiskLevel.high:
      return 'Высокий риск. Допуск запрещён.';
  }
}