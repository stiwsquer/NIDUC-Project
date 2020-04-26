%Dla BSK podaj M=2 , Dla QPSK podaj M=4
M=4;            %Ilo�� punkt�w w konstelacji sygna�u
PHASE = pi/M;   %Przesuni�cie fazy
bitInput = true;    %Zaznaczenie czy dane wchodz�ce do modulatora to warto��i binarne czy ca�kowitoliczbowe
bitOutput = true;   %Zaznaczenie czy dane wychodz�ce z demodulatora to warto��i binarne czy ca�kowitoliczbowe
amountOfBits = 1000; %Ilo�� bit�w przechodz�cych przez kana� transmisyjny
%Modulator i demodulator
pskModulator = comm.PSKModulator(M,PHASE,'BitInput',bitInput); %Stworzenie obiektu modulatora
%constellation(pskModulator); %Konstelacja modulatora
pskDemodulator = comm.PSKDemodulator(M,PHASE,'BitOutput',bitOutput);   %Stworzenie obiektu demodulatora
%Stworzenie obiektu ErrorRate
errorRate = comm.ErrorRate; %Stworzenie obiektu errorRate do �ledzenia statystyk BER(bit error rate)
%Dane
data = randi([0 1],amountOfBits,1);
%Kana� transmisyjny
awgnChannel = comm.AWGNChannel('BitsPerSymbol',log2(M)); %Stworzenie obiektu reprezentuj�cego kana� transmisyjny. 
awgnChannel.NoiseMethod = 'Signal to noise ratio (SNR)';   %SNR -stosunek mocy sygna�u do mocy szumu
%modulujemy dane
modulatedData = pskModulator(data);
scatterplot(modulatedData);
legend('modulatedData');

%przepuszczenie przez kana�,demodulacja oraz wykresy wskazowe dla SNR=20,10,1,0.1
vec = [20 10 1 0.1];
for i=1:length(vec)
    release(errorRate);
    awgnChannel.SNR = vec(i);      %Warto�� SNR w decybelach
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
    display('Ilo�� b��d�w: ');
    display(berSNR(2));
end


%Zwolnienie Kana�u transmisyjnego i utworzenie nowego
release(awgnChannel);
awgnChannel = comm.AWGNChannel('BitsPerSymbol',log2(M)); %Stworzenie obiektu reprezentuj�cego kana� transmisyjny
%przepuszczenie przez kana�,demodulacja oraz wykresy wskazowe dla EbNo=20,10,1,0.1
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
    display('Ilo�� b��d�w: ');
    display(berSNR(2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Por�wnaneie Teoretycznych warto��i BER oraz symulowanych
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Stworzenie wektor�w do symulacji
ebnoDec = 1:10; %wektor decybeli 
ber = zeros(size(ebnoDec));
%Oszacowymanie BER przez modulacje danych binarnych,przepuszczenie ich
%przez kana� AWGN, demodulacje sygna�u i zebranie statycsyk b��d�w
for k=1:length(ebnoDec)
    %Resetujemy licznik b��d�w
    reset(errorRate);
    %Resetujemy tablice do zbierania statystyk b��d�w
    errVec = [0 0 0];
    %Ustawiamy stouenk stosunek mocy sygna�u do mocy szumu w kanale (SNR)
    awgnChannel.EbNo = ebnoDec(k);
    
    while errVec(2)<200 && errVec(3)<1e7
        %Generujemy dane 
        data = randi([0 1],amountOfBits,1);
        %Modulujemy dane 
        modData = pskModulator(data);
        %Przepuszczamy zmodulowane dane przez kana� transmisyjny
        signal = awgnChannel(modData);
        %Demodulujemy odebrany sygna�
        demodData = pskDemodulator(signal);
        %zbieramy statystyki b��d�w
        errVec = errorRate(data,demodData);
    end
    %Zapisujemy Bit error rate dla danej warto�ci SNR
    ber(k) = errVec(1);
end
%Generujemy teoretyczne dane dla kana�u AWGN 
berTheory = berawgn(ebnoDec,'psk',M,'nondiff');
%Teoretyczne i zasymulowane dane przedstawiamy na wykresie 
figure
semilogy(ebnoDec,[ber;berTheory]);
xlabel('Eb/No (dB)');
ylabel('BER');
grid
legend('Symulacja','Teoria','location','ne');



