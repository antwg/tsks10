function [zI, zQ, A, tau] = receiver(y)
    % Frequency band
    f_low = 35e3; 
    fc = 45e3;
    f_high = 55e3; 
    
    % -------------------------- Incoming signal --------------------------
    
    % Time
    fs = 400e3;
    Ts = 1/fs;
    L = length(y);
    t = Ts*[0:L-1];
    
    % Frequency
    f = fs*[0:L-1]/L;
    Y = abs(fft(y));
    
    %figure
    %plot(t, y);
    
    % Plot frequency
    %figure()
    %plot(f,Y);
    
    % --------------------- BP-filter out freq. band ----------------------
    % BP filter with cut-off slightly more narrow than given band 
    % (35.1kHz - 54.9kHz)
    num_of_poles = 200;
    [b, a] = fir1(num_of_poles, [0.1755 0.2745]);
    y = filter(b, a, y);
    
    % Correct time delay 
    y = circshift(y, -num_of_poles/2);
    
    % --------------------- Find channel properties -----------------------

    % Create local chirp
    tchirp = Ts*[0:1*fs-1]';
    fchirp0 = f_low + 9.9e3;
    fchirp1 = f_high - 9.9e3;
    local_chirp = 0.1*chirp(tchirp, fchirp0, 1, fchirp1);
    
    % Correlate to find properties
    [corr, lag] = xcorr(y, local_chirp);
    
    % Delay found when correlation is largest
    [val, delay] = max(abs(corr));
    % How much shifted att delay
    delay_samples = lag(delay);
    % Convert to seconds
    delay_seconds = delay_samples/fs;
    % Convert to microseconds with one decimal
    tau = round(delay_seconds, 7) * 1e6;
    % Remove chirp, 1 seconds + delay_samples
    received_chirp = y(delay_samples + 1:fs*1 + delay_samples);
    y = y(fs*1 + delay_samples + 1: L);
    L = length(y);
    t = Ts*[0:L-1];
    
    %figure
    %plot(sent_chirp);
    
    % Find the amplitude by comparing the signal energy before and after 
    % the channel
    local_chirp_norm = norm(local_chirp);
    received_chirp_norm = norm(received_chirp);
    
    amplitude_sign = sign(corr(delay));
    A = round(received_chirp_norm / local_chirp_norm * amplitude_sign, 1);
    y = y/A;
    
    %figure;
    %plot(corr);
    
    % ------------------------- I/Q demodulation --------------------------
    % Demodulate before downsample to avoid aliasing
    zI = 2*y.*cos(2*pi*fc*t)';
    zQ = -2*y.*sin(2*pi*fc*t)';
    
    %figure
    %plot(t, zI, t, zQ);
    
    % Frequency
    f = fs*[0:L-1]/L;
    ZI = abs(fft(zI));
    ZQ = abs(fft(zQ));
    
    %figure() 
    %plot(f, ZI, f, ZQ)
    
    % ----------------------------- LP-filter -----------------------------
    
    % Part of demodulation
    num_of_poles = 200;
    [b, a] = fir1(num_of_poles, 0.05);
    zI = filter(b, a, zI);
    zQ = filter(b, a, zQ);
    
    % Frequency
    ZI = abs(fft(zI));
    ZQ = abs(fft(zQ));
    
    % Plot time after LP-filter
    %figure
    %plot(t, zI, t, zQ);
    
    % Plot frequency after filter
    %figure
    %plot(f,ZI, f, ZQ);
    
    % Correct time delay 
    zI = circshift(zI, -num_of_poles/2);
    zQ = circshift(zQ, -num_of_poles/2);
    
    %figure
    %plot(t, y);
    
    % ---------------------------- Downsample -----------------------------
    M = 20; % Downsampling factor
    zI = downsample(zI, M);
    zQ = downsample(zQ, M);
    
    % Time
    L = length(zI);
    t = Ts*[0:L-1];
    
    %figure
    %plot(t, zI, t, zQ)
    
    % Frequency
    f = fs*[0:L-1]/L;
    ZI = abs(fft(zI));
    ZQ = abs(fft(zQ));
    
    % Hårdkoda storlek på signalerna så de stämmer med xI och xQ.
    zI = zI(1:100000);
    zQ = zQ(1:100000);

    
    %figure
    %plot(f,ZI, f, ZQ);
end