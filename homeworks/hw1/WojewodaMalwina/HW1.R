library(PogromcyDanych)
library(dplyr)

colnames(auta2012)
dim(auta2012)
head(auta2012[,-ncol(auta2012)])
sum(is.na(auta2012))

## Malwina Wojewoda

## 1. Z kt�rego rocznika jest najwi�cej aut i ile ich jest?
auta2012 %>% 
  group_by(Rok.produkcji) %>% 
  summarise(liczbaAut_rocznik = n()) %>% 
  arrange(desc(liczbaAut_rocznik)) %>% 
  head(1)
## Odp: 2011  17418


## 2. Kt�ra marka samochodu wyst�puje najcz�ciej w�r�d aut wyprodukowanych w 2011 roku?
auta2012 %>% 
  filter(Rok.produkcji == 2011) %>% 
  group_by(Marka) %>% 
  summarise(liczbaAut_marka = n()) %>% 
  arrange(desc(liczbaAut_marka)) %>% 
  head(1)
## Odp: Skoda


## 3. Ile jest aut z silnikiem diesla wyprodukowanych w latach 2005-2011?
auta2012 %>% 
  filter(Rodzaj.paliwa == "olej napedowy (diesel)" & 
         Rok.produkcji >= 2005 & 
         Rok.produkcji <= 2011) %>% 
  nrow()
## Odp: 59534


## 4. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2011 roku, kt�ra marka jest �rednio najdro�sza?
auta2012 %>% 
  filter(Rodzaj.paliwa == "olej napedowy (diesel)" & 
         Rok.produkcji == 2011) %>% 
  group_by(Marka) %>% 
  summarise(sredni_koszt = mean(Cena.w.PLN, na.rm = TRUE)) %>% 
  arrange(desc(sredni_koszt)) %>% 
  head(1)
## Odp: Porche


## 5. Spo�r�d aut marki Skoda wyprodukowanych w 2011 roku, kt�ry model jest �rednio najta�szy?
auta2012 %>% 
  filter(Marka == "Skoda" & 
           Rok.produkcji == 2011) %>% 
  group_by(Model) %>% 
  summarise(srednia_cena = mean(Cena.w.PLN, na.rm = TRUE)) %>% 
  arrange(srednia_cena) %>% 
  head(1)
## Odp: Fabia


## 6. Kt�ra skrzynia bieg�w wyst�puje najcz�ciej w�r�d 2/3-drzwiowych aut,
##    kt�rych stosunek ceny w PLN do KM wynosi ponad 600?
auta2012 %>% 
  filter(Liczba.drzwi == "2/3"&
         Cena.w.PLN/KM > 600) %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(ktora_skrzynia = n()) %>%
  arrange(desc(ktora_skrzynia)) %>%
  head(1)
## Odp: automatyczna


## 7. Spo�r�d aut marki Skoda, kt�ry model ma najmniejsz� r�nic� �rednich cen 
##    mi�dzy samochodami z silnikiem benzynowym, a diesel?
auta2012 %>% 
  filter(Marka == "Skoda" &
         Rodzaj.paliwa == "benzyna") %>% 
  group_by(Model) %>% 
  summarise(srednia_cena_benzyna = mean(Cena.w.PLN, na.rm = TRUE)) -> benzyna

auta2012 %>% 
  filter(Marka == "Skoda" &
         Rodzaj.paliwa == "olej napedowy (diesel)") %>% 
  group_by(Model) %>% 
  summarise(srednia_cena_diesel = mean(Cena.w.PLN, na.rm = TRUE)) -> diesel

inner_join(benzyna, diesel, by = 'Model') %>% 
  mutate(roznica = abs(srednia_cena_benzyna-srednia_cena_diesel)) %>% 
  arrange(roznica) %>%                 
  head(1)
## Odp: Felicia


## 8. Znajd� najrzadziej i najcz�ciej wyst�puj�ce wyposa�enie/a dodatkowe 
##    samochod�w marki Lamborghini
library(stringr)

auta2012 %>% 
  filter(Marka == "Lamborghini") -> lambo

data.frame(wyposazenie = 
  unlist(
    str_split(lambo$Wyposazenie.dodatkowe, ", "))) %>% 
  group_by(wyposazenie) %>% 
  summarise(jak_czesto = n()) %>% 
  arrange(jak_czesto) -> jakCzestoWyposazenie
slice_max(jakCzestoWyposazenie, jak_czesto)
slice_min(jakCzestoWyposazenie, jak_czesto)
## Odp: Najrzadziej: blokada skrzyni bieg�w, klatka
##      Najcz�ciej: ABS, alufelgi, wspomaganie kierownicy

## 9. Por�wnaj �redni� i median� mocy KM mi�dzy grupami modeli A, S i RS 
##    samochod�w marki Audi
auta2012 %>% 
  filter(Marka == "Audi") %>% 
  mutate(Modele_wybrane = case_when(str_starts(Model, "A") ~ "A",
                                    str_starts(Model, "S") ~ "S",
                                    str_starts(Model, "RS") ~ "RS",
                                    TRUE ~ "Pozosta�e")) %>% 
  group_by(Modele_wybrane) %>% 
  summarise(Srednia_moc = mean(KM, na.rm = TRUE), 
            Mediana_moc = median(KM, na.rm = TRUE), 
            Czy_srednia_wieksza = Srednia_moc > Mediana_moc,
            Jaka_roznica = abs(Srednia_moc - Mediana_moc)) %>% 
  filter(Modele_wybrane == "A" | 
         Modele_wybrane == "S" | 
         Modele_wybrane == "RS")
## Odp: A: �rednia wi�ksza od mediany o 19.6
##      R: �rednia mniejsza od mediany o 0.263
##      RS: �rednia wi�ksza od mediany o 50.0


## 10. Znajd� marki, kt�rych auta wyst�puj� w danych ponad 10000 razy.
##     Podaj najpopularniejszy kolor najpopularniejszego modelu dla ka�dej z tych marek.
auta2012 %>% 
  group_by(Marka) %>% 
  summarise(liczbaAut = n()) %>%
  filter(liczbaAut>10000) -> popularne_auta

inner_join(popularne_auta, auta2012, by = "Marka") %>% 
  group_by(Marka, Model) %>% 
  summarise(ile_model = n()) %>% 
  top_n(1) -> popularne_modele

inner_join(popularne_modele, auta2012) %>% 
  group_by(Marka, Model, Kolor) %>% 
  summarise(ile_kolor = n()) %>% 
  top_n(1) 
## Odp: Audi          A4     czarny-metallic    
#       BMW           320    srebrny-metallic     
#       Ford          Focus  srebrny-metallic     
#       Mercedes-Benz C 220  srebrny-metallic     
#       Opel          Astra  srebrny-metallic     
#       Renault       Megane srebrny-metallic     
#       Volkswagen    Passat srebrny-metallic

