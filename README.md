# Salary-Poland-PLN-USD

* [Dane](#Dane)
* [Opis działania skryptu](#Opis)
* [Prezentacja wyników](#Wizualizacja)
* [Wykorzystana technologia](#Technologia)

## Dane

Dane o historycznych średnich wynagrodzeniach w Polsce zostały pobrane z API banku danych lokalnych.

URL: https://api.stat.gov.pl/Home/BdlApi

Dane o historycznych kursach pary walutowej USD/PLN zostały pobrane z API NBP.

URL: https://api.nbp.pl/

## Opis

W pierwszej części skryptu pobierane są dane o średnich wynagrodzeniach na przestrzeni badanych lat z API Banku Danych Lokalnych. Następnie przy pomocy wbudowanego
komponentu sasowego pozwalającego obsługiwać pliki JSON, załadowana zostaje tabela z informacjami bezpośrednio do biblioteki WORK.

W drugiej części skryptu pobierane są dane o kursie pary walutowej USD/PLN. Api NBP udostępnia tylko kursy walut dla konkretnej daty, w zwiazku z tym skrypt SASowy 
odpytuje API NBP za każdy konkretny dzień (od początku 2002 roku do dzisiaj) o poziom kursów walut, następnie oblicza średnią relację dla wskazanej pary 
walutowej dla każdego z badanych lat.

## Wizualizacja

![PLN_USD_SALARY img](https://github.com/WHHY100/Salary-Poland-PLN-USD/blob/main/img/SALARY_POLAND_USD_CHART.jpg?raw=true)

Powyższy wykres prezentuje przecietną pensję w Polsce w latach 2002 - 2021. Niebieskie słupki prezentują poziom wynagrodzenia w złotówkach. Na wykresie widać, że
z roku na rok przeciętne wynagrodzenie podawane przez Główny Urząd Statystyczny systematycznie wzrasta. Czerwona kreska wizualizuje natomiast poziom wynagrodzeń w Polsce 
(przeliczony po średniorocznym kursie pary walutowej USD/PLN) wyrażony w dolarach. O ile średnie wynagrodzenie w złotówkach rośnie dość znacznie, o tyle
wynagrodzenie wyrażone w dolarach charakteryzuje się znacznie niższą tendencja wzrostową. W niektórych okresach (np. w roku 2009), możemy zauważyć,
że mimo wzrostu wynagrodzenia nominalnego w złotówkach, wynagrodzenie wyrażone w dolarach znacząco spadło co było spowodowane spadkiem wartości polskiej złotówki.
W 2009 roku sytuację tą możemy tłumaczyć ogólnoświatowym kryzysem gospodarczym i charakterystycznym dla takich okresów umacnianiem się "twardych" walut.

![PLN_USD_SALARY_TAB img](https://github.com/WHHY100/Salary-Poland-PLN-USD/blob/main/img/SALARY_POLAND_USD.jpg?raw=true)

Powyższa tabela przedstawia zagregowane dane na podstawie których został stworzony wcześniej przedstawiony wykres. W pierwszej kolumnie widzimy okres (rok) dla
jakiego zostały wykonane obliczenia, w drugiej oszacowany na podstawie danych z NBP średnioroczny kurs pary walutowej USD/PLN, a w dwóch kolejnych odpowiednio
wynagrodzenie w polskiej złotówce i wynagrodzenie wyrażone w dolarze amerykańskim przeliczone po kursie odpowiednim dla badanego okresu.

## Technologia

*SAS Studio* ® w SAS® OnDemand

Wersja: *9.4_M6*
