
function x = sender(xI, xQ)
    % Frequency band
    f_low = 35e3; 
    fc = 45e3;
    f_high = 55e3; 

    % -------------------------- Original signal --------------------------
    
    % Time
    fs = 400e3;
    Ts = 1/fs;
    L = length(xI);
    t = Ts*[0:L-1];
    
    % Frequency
    f = fs*[0:L-1]/L;
    XI = abs(fft(xI));
    XQ = abs(fft(xQ));
    
    % Plot time
    %figure
    %plot(t, xI, t, xQ);
    
    % Plot frequency
    %figure
    %plot(f,XI, f, XQ);
 
    % ----------------------------- Upsample ------------------------------
    
    % Upsample xI and xQ to 400 kHz by using a factor of 20 
    M = 20; % Upsampling factor
    xI = upsample(xI, M);
    xQ = upsample(xQ, M);
    
    % Time
    L = length(xI);
    t = Ts*[0:L-1];
    
    % Frequency
    f = fs*[0:L-1]/L;
    XI = abs(fft(xI));
    XQ = abs(fft(xQ));
    
    % Plot time after upsample
    %figure
    %plot(t, xI, t, xQ);
    
    % Plot frequency after upsample
    %figure
    %plot(f,XI, f, XQ);

    % ----------------------------- LP-filter -----------------------------
    
    % The upsampled signal needs to be LP filtered
    % to interpolate between the original samples, 
    % the LP cut-off frequency is 10 kHz, 10kHz / (0.5*400kHz)= 0.05.
    % 0.5 * 400kHz because of how matlab handles cut-off frequency
    num_of_poles = 200;
    [b, a] = fir1(num_of_poles, 0.05);
    xI = filter(b, a, xI);
    xQ = filter(b, a, xQ);
    
    % Frequency
    XI = abs(fft(xI));
    XQ = abs(fft(xQ));
    
    % Plot time after LP-filter
    %figure
    %plot(t, xQ, t, xI);
    
    % Plot frequency after filter
    %figure
    %plot(f,XI, f, XQ);

    % ------------------------- Correct amplitude -------------------------
    
    % Scale the amplitude to counteract the energy loss from inserting
    % the zeroes
    xI = M * xI;
    xQ = M * xQ;
    
    % ------------------------ Correct time delay -------------------------
    
    % FIR filters create a delay of n/2 where n = number of poles
    xI = circshift(xI, -num_of_poles/2);
    xQ = circshift(xQ, -num_of_poles/2);
    
    %figure
    %plot(t, xI, t, xQ);
    
    % -------------------------- I/Q modulation ---------------------------
    
    x = xI.*cos(2*pi*fc*t)' - xQ.*sin(2*pi*fc*t)';
    X = abs(fft(x));
    
    % Plot time after I/Q
    %figure
    %plot(t, x);
    
    % Plot frequency after I/Q
    %figure
    %plot(f, X);
    
    % ----------------------------- Add chirp -----------------------------
    % Adds a 5 seconds long chirp to the start of the signal
    
    fchirp0 = f_low + 9.9e3;
    fchirp1 = f_high - 9.9e3;
    c = 0.1*chirp(t, fchirp0, 5, fchirp1);
    x = cat(1, c', x);
    
    X = abs(fft(x));
    L = length(x);
    f = fs*[0:L-1]/L;
    
    % Plot time
    %figure 
    %plot(x)
    
    % Plot frequency
    %figure
    %plot(f, X);
end