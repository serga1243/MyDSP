classdef ResearchRadioPulse < ResearchSignal
    properties
        T
        Ti
        F
        Phi
    end
    
    %%
    methods (Access = public)
        function obj = ResearchRadioPulse(NFFTl, NFFTs, ...
                timeSample, numSample, quantization, dSignalNoise, deltaParametr,...
                T, Ti, F, Phi)
            obj = obj@ResearchSignal(NFFTl, NFFTs,...
                timeSample, numSample, quantization, dSignalNoise, deltaParametr);
            obj.T = T;
            obj.Ti = Ti;
            obj.F = F;
            obj.Phi = Phi;
        end      
    end
    
    %%
    methods (Access = public)
%         function [T, Ti, F, Phi] = searchRadioPulse(obj, SA_bshort, SA_fshort, SA_blong, SA_flong)     
%             Ebini = sum(SA_blong, 1);
%             Emax = sum(Ebini);
%             Ebini = Ebini/Emax;
%             
%             F = sum(Ebini.*(1:obj.NFFTlong)./obj.Ts/obj.NFFTlong);
%             T = [];
%             Ti = [];
%             Phi = [];
%         end

        function [T, Ti, F, Phi] = searchRadioPulse(obj, SA_b, SA_f, SP)
            [len1, len2] = size(SA_b);
            TDistrib = zeros([1 len1], 'double');
            TiDistrib = zeros([1 len1], 'double');
            amplDistrib = zeros([1 len2], 'double');
            phasDistrib = zeros([1 len2], 'double');
            
            j = uint32(0);
            k = uint32(0);
            for i = 1:len1
                Esum = sum(SA_b(i,:));
                if Esum ~= 0
                    Ebini = SA_b(i,:)/Esum;
                    
                    F = sum(Ebini.*(1:len2)./obj.Ts/len2);
                    F = ceil(F/225e6*len2);
                    amplDistrib(F) = amplDistrib(F) + 1;
                    phasDistrib(F) = SP(i,F);
                    
                    if k ~= 0
                        TDistrib(k) = TDistrib(k) + 1;
                    end
                    j = j + 1;
                    k = 0;
                elseif Esum == 0
                    if j ~= 0
                        TiDistrib(j) = TiDistrib(j) + 1;
                    end
                    k = k + 1;
                    j = 0;
                end
            end
            
            [~, T] = max(TDistrib);
            [~, Ti] = max(TiDistrib);
            [~, F] = max(amplDistrib);
            Phi = abs(phasDistrib(F));
        end
    end
    
    methods (Access = public)
        %% T
        function PD = researchT(obj, i, j, k, A, step)
            count = 0;
            for i1 = 1:length(obj.Phi)
                for i2 = 1:length(obj.F)
                    for i3 = 1:length(obj.Ti)
                        for i4 = 1:length(obj.T)
                            s = Signals(obj.Ts, obj.Ns);
                            s = s.genRadioPulse([0 obj.Ns], 1, obj.T(i4), obj.Ti(i3), obj.F(i2), obj.Phi(i1));
                            s = s.addNoise([0 obj.Ns], "randn", obj.dsn(j));
                            
                            s = s.quantizeSignal(obj.qb(i));
                            
                            if obj.Ti(i3) < step*obj.NFFTlong*obj.Ts
                                [SA, SP] = s.spectrumQ(obj.NFFTshort);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTshort;
                            else
                                [SA, SP] = s.spectrumQ(obj.NFFTlong);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTlong;
                            end
                            
                            [TMesh, ~, ~, ~] = searchRadioPulse(obj, SA_b, SA_f, SP);  
                            objT = round(obj.T(i4)/obj.Ts/NFFT); 
                            deltaT = 100*(TMesh - objT)/objT;
                            
                            if abs(deltaT) < abs(obj.dp(k))
                                count = count + 1;
                            end
                        end
                    end
                end
            end
            
            PD = count/i1/i2/i3/i4;
        end
        
        %% Ti
        function PD = researchTi(obj, i, j, k, A, step)
            count = 0;
            for i1 = 1:length(obj.Phi)
                for i2 = 1:length(obj.F)
                    for i3 = 1:length(obj.T)
                        for i4 = 1:length(obj.Ti)
                            s = Signals(obj.Ts, obj.Ns);
                            s = s.genRadioPulse([0 obj.Ns], 1, obj.T(i3), obj.Ti(i4), obj.F(i2), obj.Phi(i1));
                            s = s.addNoise([0 obj.Ns], "randn", obj.dsn(j));
                            
                            s = s.quantizeSignal(obj.qb(i));
                            
                            if obj.Ti(i4) < step*obj.NFFTlong*obj.Ts
                                [SA, SP] = s.spectrumQ(obj.NFFTshort);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTshort;
                            else
                                [SA, SP] = s.spectrumQ(obj.NFFTlong);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTlong;
                            end
                            
                            [~, TiMesh, ~, ~] = searchRadioPulse(obj, SA_b, SA_f, SP);
                            objTi = round(obj.Ti(i4)/obj.Ts/NFFT);
                            deltaTi = 100*(TiMesh - objTi)/objTi;
                            
                            if abs(deltaTi) < abs(obj.dp(k))
                                count = count + 1;
                            end
                        end
                    end
                end
            end
            
            PD = count/i1/i2/i3/i4;
        end
        
        %% F
        function PD = researchF(obj, i, j, k, A, step)
            count = 0;
            for i1 = 1:length(obj.Phi)
                for i2 = 1:length(obj.Ti)
                    for i3 = 1:length(obj.T)
                        for i4 = 1:length(obj.F)
                            s = Signals(obj.Ts, obj.Ns);
                            s = s.genRadioPulse([0 obj.Ns], 1, obj.T(i3), obj.Ti(i2), obj.F(i4), obj.Phi(i1));
                            s = s.addNoise([0 obj.Ns], "randn", obj.dsn(j));
                            
                            s = s.quantizeSignal(obj.qb(i));
                            
                            if obj.Ti(i2) < step*obj.NFFTlong*obj.Ts
                                [SA, SP] = s.spectrumQ(obj.NFFTshort);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTshort;
                            else
                                [SA, SP] = s.spectrumQ(obj.NFFTlong);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                                NFFT = obj.NFFTlong;
                            end
                            
                            [~, ~, FMesh, ~] = searchRadioPulse(obj, SA_b, SA_f, SP);
                            objF = ceil(obj.F(i4)*obj.Ts*NFFT);
                            deltaF = 100*(FMesh - objF)/objF;
                            
                            if abs(deltaF) < abs(obj.dp(k))
                                count = count + 1;
                            end
                        end
                    end
                end
            end
            
            PD = count/i1/i2/i3/i4;
        end
        
        %% Phi
        function PD = researchPhi(obj, i, j, k, A, step)
            count = 0;
            for i1 = 1:length(obj.F)
                for i2 = 1:length(obj.Ti)
                    for i3 = 1:length(obj.T)
                        for i4 = 1:length(obj.Phi)
                            s = Signals(obj.Ts, obj.Ns);
                            s = s.genRadioPulse([0 obj.Ns], 1, obj.T(i3), obj.Ti(i2), obj.F(i1), obj.Phi(i4));
                            s = s.addNoise([0 obj.Ns], "randn", obj.dsn(j));
                            
                            s = s.quantizeSignal(obj.qb(i));
                 
                            if obj.Ti(i2) < step*obj.NFFTlong*obj.Ts
                                [SA, SP] = s.spectrumQ(obj.NFFTshort);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                            else
                                [SA, SP] = s.spectrumQ(obj.NFFTlong);
                                [SA_b, SA_f] = findFreq(s, SA, A);
                            end
                            
                            [~, ~, ~, PhiMesh] = searchRadioPulse(obj, SA_b, SA_f, SP);
                            deltaPhi = 100*(PhiMesh - obj.Phi(i4))/obj.Phi(i4);
                            
                            if abs(deltaPhi) < abs(obj.dp(k))
                                count = count + 1;
                            end
                        end
                    end
                end
            end
            
            PD = count/i1/i2/i3/i4;
        end
    end  
end

