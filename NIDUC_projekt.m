%Dla BSK podaj M=2 , Dla QPSK podaj M=4
M=4;            %Iloœæ punktów w konstelacji sygna³u
PHASE = pi/M;   %Przesuniêcie fazy
bitInput = true;    %Zaznaczenie czy dane wchodz¹ce do modulatora to wartoœæi binarne czy ca³kowitoliczbowe
bitOutput = true;   %Zaznaczenie czy dane wychodz¹ce z demodulatora to wartoœæi binarne czy ca³kowitoliczbowe
amountOfBits = 1000; %Iloœæ bitów przechodz¹cych przez kana³ transmisyjny
%Modulator i demodulator
pskModulator = comm.PSKModulator(M,PHASE,'BitInput',bitInput); %Stworzenie obiektu modulatora
%constellation(pskModulator); %Konstelacja modulatora
pskDemodulator = comm.PSKDemodulator(M,PHASE,'BitOutput',bitOutput);   %Stworzenie obiektu demodulatora
%Stworzenie obiektu ErrorRate
errorRate = comm.ErrorRate; %Stworzenie obiektu errorRate do œledzenia statystyk BER(bit error rate)
%Dane
data = randi([0 1],amountOfBits,1);
%Kana³ transmisyjny
awgnChannel = comm.AWGNChannel('BitsPerSymbol',log2(M)); %Stworzenie obiektu reprezentuj¹cego kana³ transmisyjny. 
awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';   %SNR -stosunek mocy sygna³u do mocy szumu
%modulujemy dane
modulatedData = pskModulator(data);
scatterplot(modulatedData);
legend('modulatedData');

%przepuszczenie przez kana³,demodulacja oraz wykresy wskazowe dla SNR=20,10,1,0.1
vec = [20 10 1 0.1];
for i=1:length(vec)
    release(errorRate);
    awgnChannel.SNR = vec(i);      %Wartoœæ SNR w decybelach
    channelOutput = awgnChannel(modulatedData);
    demodulatedData = pskDemodulator(channelOutput);
    scatterplot(channelOutput);
    if i==1
        legend('channelOutput, SNR = 20');
        display('SNR = 20');
    elseif i==2
        legend('channelOutput, SNR = 10');
        display('SNR = 10');
    elseif i==3
        legend('channelOutput, SNR = 1');
        display('SNR = 1');
    else
        legend('channelOutput, SNR = 0.1');   
        display('SNR = 0.1');
    end
    berSNR = errorRate(data,demodulatedData);
    display('BER: ');
    display(berSNR(1));
    display('Iloœæ b³êdów: ');
    display(berSNR(2));
end


%Zwolnienie Kana³u transmisyjnego i utworzenie nowego
release(awgnChannel);
awgnChannel = comm.AWGNChannel('BitsPerSymbol',log2(M)); %Stworzenie obiektu reprezentuj¹cego kana³ transmisyjny
%przepuszczenie przez kana³,demodulacja oraz wykresy wskazowe dla EbNo=20,10,1,0.1
for i=1:length(vec)
    release(errorRate);
    awgnChannel.EbNo = vec(i);      
    channelOutput = awgnChannel(modulatedData);
    demodulatedData = pskDemodulator(channelOutput);
    scatterplot(channelOutput);
    if i==1
        legend('channelOutput, EbNo = 20');
        display('EbNo = 20');
    elseif i==2
        legend('channelOutput, EbNo = 10');
        display('EbNo = 10');
    elseif i==3
        legend('channelOutput, EbNo = 1');
        display('EbNo = 1');
    else
        legend('channelOutput, EbNo = 0.1');   
        display('EbNo = 0.1');
    end
    berSNR = errorRate(data,demodulatedData);
    display('BER: ');
    display(berSNR(1));
    display('Iloœæ b³êdów: ');
    display(berSNR(2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Porównaneie Teoretycznych wartoœæi BER oraz symulowanych
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stworzenie wektorów do symulacji
ebnoDec = 1:10; %wektor decybeli 
ber = zeros(size(ebnoDec));
%Oszacowymanie BER przez modulacje danych binarnych,przepuszczenie ich
%przez kana³ AWGN, demodulacje sygna³u i zebranie statycsyk b³êdów
for k=1:length(ebnoDec)
    %Resetujemy licznik b³êdów
    reset(errorRate);
    %Resetujemy tablice do zbierania statystyk b³êdów
    errVec = [0 0 0];
    %Ustawiamy stouenk stosunek mocy sygna³u do mocy szumu w kanale (SNR)
    awgnChannel.EbNo = ebnoDec(k);
    
    while errVec(2)<200 && errVec(3)<1e7
        %Generujemy dane 
        data = randi([0 1],amountOfBits,1);
        %Modulujemy dane 
        modData = pskModulator(data);
        %Przepuszczamy zmodulowane dane przez kana³ transmisyjny
        signal = awgnChannel(modData);
        %Demodulujemy odebrany sygna³
        demodData = pskDemodulator(signal);
        %zbieramy statystyki b³êdów
        errVec = errorRate(data,demodData);
    end
    %Zapisujemy Bit error rate dla danej wartoœci SNR
    ber(k) = errVec(1);
end
%Generujemy teoretyczne dane dla kana³u AWGN 
berTheory = berawgn(ebnoDec,'psk',M,'nondiff');
%Teoretyczne i zasymulowane dane przedstawiamy na wykresie 
figure
semilogy(ebnoDec,[ber;berTheory]);
xlabel('Eb/No (dB)');
ylabel('BER');
grid
legend('Symulacja','Teoria','location','ne');



