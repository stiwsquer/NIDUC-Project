N = 8;
M = [N N];
modOrder = sum(M);
randii = [0.5 1.5];
phOff = [pi/N pi/(2*N)];
bitsPerSymbol = log2(modOrder);
amountOfBits = 1000;

data = randi([0 1],bitsPerSymbol*amountOfBits,1);
modulatedData = apskmod(data,M,randii,phOff,'inputType','bit');
errorRate = comm.ErrorRate;

vecSNR = [ 0.1 1 10 20 40 80 160];
display('Szybkość transmisji (ilość bitów przesyłanych w jednym okresie fali nośnej): ');
display((bitsPerSymbol));
for i=1:length(vecSNR)
    release(errorRate);
    snr = vecSNR(i);
    channelOutput = awgn(modulatedData,snr,sigPow,'linear');
    demodulatedData = apskdemod(channelOutput,M,randii,phOff,'OutputType','bit');
    scatterplot(channelOutput);
    hold on
    grid
    plot(modulatedData,'r+')
    xlabel('In-Phase Amplitude')
    ylabel('Quadrature Amplitude')
    if i==1
        legend('channelOutput, SNR = 0.1');
        display('SNR = 0.1');
    elseif i==2
        legend('channelOutput, SNR = 1');
        display('SNR = 1');
    elseif i==3
        legend('channelOutput, SNR = 10');
        display('SNR = 10');
    elseif i==4
        legend('channelOutput, SNR = 20');
        display('SNR = 20');
    elseif i==5
        legend('channelOutput, SNR = 40');
        display('SNR = 40');
    elseif i==6
        legend('channelOutput, SNR = 80');
        display('SNR = 80');
    else
        legend('channelOutput, SNR = 160');   
        display('SNR = 160');
    end
    
    berSNR = errorRate(data,demodulatedData);
    display('Ilość bitów: ');
    display(berSNR(3));
    display('Ilość błędów: ');
    display(berSNR(2));
    display('BER: ');
    display(berSNR(1));
    
end
