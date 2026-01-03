#!/usr/bin/env zsh
# v0.1.2  aug/2025  by mountaineerbr
# dump some google weather api info
# requires google api key and weather api access enabled
#https://developers.google.com/maps/documentation/weather/current-conditions
#https://developers.google.com/maps/documentation/weather/daily-forecast

if [[ -z "${GOOGLE_API_KEY:-}" ]]; then
  print -u2 "Error: GOOGLE_API_KEY environment variable is not set."
  exit 1
fi

if command -v google_geocode.zsh >/dev/null 2>&1 &&
	GPS=$(google_geocode.zsh "$@")
then
	echo $'LOCATION\n'${GPS#*$'\t'}$'' >&2;
	IFS=$IFS, read LAT LON <<<${GPS%%$'\t'*};
else
	[[ $1$2 = *[\ ,]* ]] && set -- "${=@}";
fi
#37.4220,-122.0841"  #New York
LAT="${LAT:-${1:?err: latitude required}}";
LON="${LON:-${2:?err: longitude required}}";
echo "LAT: $LAT  LON: $LON"$'\n' >&2;


echo $'CURRENT CONDITIONS' >&2;

curl -sL -X GET "https://weather.googleapis.com/v1/currentConditions:lookup?key=${GOOGLE_API_KEY}&location.latitude=${LAT}&location.longitude=${LON}" |
jq -r '(
  ["Time", "TimeZone", "Condition", "Temp(C)", "FeelsLike(C)", "Humidity(%)", "Wind(km/h)", "Gust(km/h)", "Visibility(km)"],
  [.currentTime, .timeZone.id, .weatherCondition.description.text, .temperature.degrees, .feelsLikeTemperature.degrees, .relativeHumidity, .wind.speed.value,
.wind.gust.value, .visibility.distance] ) | @tsv' | column -t -s $'\t';


echo $'\n10-DAY FORECAST' >&2;

curl -sL -X GET "https://weather.googleapis.com/v1/forecast/days:lookup?key=${GOOGLE_API_KEY}&location.latitude=${LAT}&location.longitude=${LON}&days=10&pageSize=10" |
jq -r '
  ["Date", "Max(C)", "Min(C)", "Day", "Night", "Pcp(%)", "Gust(kmh)", "Dir", "Sunrise", "Sunset", "Moon"],
  (
    .forecastDays[] |
    [
      (.displayDate | "\(.year)-\(("0" + (.month|tostring))[-2:])-\(("0" + (.day|tostring))[-2:])"),
      .maxTemperature.degrees,
      .minTemperature.degrees,
      .daytimeForecast.weatherCondition.description.text,
      .nighttimeForecast.weatherCondition.description.text,
      .daytimeForecast.precipitation.probability.percent,
      .daytimeForecast.wind.gust.value,
      .daytimeForecast.wind.direction.cardinal,
      (.sunEvents.sunriseTime | sub(".*T"; "") | sub("\\..*Z"; "")),
      (.sunEvents.sunsetTime | sub(".*T"; "") | sub("\\..*Z"; "")),
      .moonEvents.moonPhase
    ]
  )
| @tsv' | column -t -s $'\t';
