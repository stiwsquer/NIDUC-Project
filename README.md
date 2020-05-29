# NIDUC-Project

PSK:
W naszym symulatorze zmiana pomiędzy QPSK a BSK następuje poprzez zmianę wartości M, odpowiednio na 4 lub na 2.
Nasz program wyświetla 10 wykresów. Pierwszy to wykres obrazujący rozmieszczenie zmodulowanych danych na wykresie
wskazowym. Następne 4 to  wykresy wskazowe dla konkretnych wartości (20,10,1,0.1 dB) SNR (Ratio of signal power to noise power).
Kolejne 4 to  wykresy wskazowe dla konkretnych wartości (20,10,1,0.1 dB)EbNo (Ratio of energy per bit to noise power spectral density).
Ostatni wykres obrazuje porównanie przebiegu symulacji i teorii BER (bit error rate) dla 10 decybeli (1,2,...,10), 
dla metody zaszumiania w kanale EbNo. Ponadto dla wykresów od 2 do 9 program wyświetla w Command Wimdow wartośc BER oraz ilość wszystkich błędów 
dla danej wartośći SNR lub EbNo.
