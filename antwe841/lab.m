clear              
close all          
clc                

[xI,fs] = audioread('xI.wav');
[xQ,fs] = audioread('xQ.wav');
x = sender(xI,xQ);
y = TSKS10channel(x);
[zI,zQ,A,tau] = receiver(y);

SNRzI = 20*log10(norm(xI)/norm(zI-xI))
SNRzQ = 20*log10(norm(xQ)/norm(zQ-xQ))
calculated_samples = 4 * tau / 10;

%soundsc(xI, 20000);
%soundsc(zI, 20000);

