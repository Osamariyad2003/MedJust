const Map<String, String> yearMapping = {
  "mYBeU7E0AOnV4vT3unao": "Year 4",
  "nkPdO6jRJWv4e3p82X7J": "Year 5",
  "mTvQXFNxnXBcguVmSVf9": "Year 6",
  "MPy1QnToFKEvLz9FT4lV": "Year 1",
  "IeWtqkLK8KkafCuJmPdY": "Year 3",
  "3Hpwliv9Va5eRH8JYS6M": "Year 2",
};

String? getYearName(String yearId) {
  return yearMapping[yearId];
}
