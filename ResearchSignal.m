classdef ResearchSignal
    properties
        Ts
        Ns
        qb
        dsn
        dp
        RadioPulse
        NFFTlong
        NFFTshort
    end
    
    methods (Access = public)
        function obj = ResearchSignal(NFFTl, NFFTs,...
                timeSample, numSample, quantization, dSignalNoise, deltaParametr)
            obj.Ts = timeSample;
            obj.Ns = numSample;
            obj.qb = quantization;
            obj.dsn = dSignalNoise;
            obj.dp = deltaParametr;
            obj.NFFTlong = NFFTl;
            obj.NFFTshort = NFFTs;
        end
    end
    
    methods (Access = public)
        function obj = searchRadioPulse(obj, A, step, rT, rTi, rF, rPhi, parametrType)
            printMessage(1, false);
            
            search = ResearchRadioPulse(obj.NFFTlong, obj.NFFTshort,...
                obj.Ts, obj.Ns, obj.qb, obj.dsn, obj.dp,...
                rT, rTi, rF, rPhi);
            
            obj.RadioPulse = {[]; []; []; []};
            
            obj.RadioPulse{1} = zeros([length(obj.qb) length(obj.dsn) length(obj.dp)],...
                'double');
            obj.RadioPulse{2} = zeros([length(obj.qb) length(obj.dsn) length(obj.dp)],...
                'double');
            obj.RadioPulse{3} = zeros([length(obj.qb) length(obj.dsn) length(obj.dp)],...
                'double');
            obj.RadioPulse{4} = zeros([length(obj.qb) length(obj.dsn) length(obj.dp)],...
                'double');
            
            len1 = uint32(length(obj.qb));
            len2 = uint32(length(obj.dsn));
            len3 = uint32(length(obj.dp));
            cout = uint32(0);
            ct =   uint8(1);
            
            for i = 1:len1
                for j = 1:len2
                    for k = 1:len3
                        tic;
                        if sum(parametrType == "T") > 0
                            obj.RadioPulse{1}(i,j,k) = search.researchT(i, j, k, A, step);
                        end
                        if sum(parametrType == "Ti") > 0
                            obj.RadioPulse{2}(i,j,k) = search.researchTi(i, j, k, A, step);
                        end
                        if sum(parametrType == "F") > 0
                            obj.RadioPulse{3}(i,j,k) = search.researchF(i, j, k, A, step);
                        end
                        if sum(parametrType == "Phi") > 0
                            obj.RadioPulse{4}(i,j,k) = search.researchPhi(i, j, k, A, step);
                        end
                        if ct == 12
                            ct = 1;
                        end
                        ct = ct + 1;
                        cout = cout + 1;
                        time = toc;
                        printMessage(2, time, [cout len1 len2 len3], ct);
                    end
                end
            end
            printMessage(3); 
        end
        
        function [] = VisualiseResults(obj, signalType, parametrType)
            printMessage(4, signalType, parametrType);  
            vis = VisualiseResultsOfResearch(obj.NFFTlong, obj.NFFTshort,...
                obj.Ts, obj.Ns, obj.qb, obj.dsn, obj.dp);
            
            switch signalType
                case "RadioPulse"
                    switch parametrType
                        case "T"
                            vis.visualise(obj.RadioPulse{1}, signalType, parametrType);
                        case "Ti"
                            vis.visualise(obj.RadioPulse{2}, signalType, parametrType);
                        case "F"
                            vis.visualise(obj.RadioPulse{3}, signalType, parametrType);
                        case "Phi"
                            vis.visualise(obj.RadioPulse{4}, signalType, parametrType);
                        otherwise
                            return;
                    end
                case "LFM"                   
                otherwise
                    return;
            end
        end
        
        
    end
    
end

