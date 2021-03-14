classdef VisualiseResultsOfResearch < ResearchSignal
    properties
    end
    
    methods (Access = public)     
        function visualise(obj, search, signalName, parName)
            for i = 1:length(obj.qb)
                figure('Name', sprintf('%s, %s, qb = %i',...
                    signalName, parName, obj.qb(i)));
                subplot(1,1,1);
                subplot('position', [0.05 0.1 0.9 0.8]);
                title(sprintf(...
                    'Исследование параметра %s сигнала типа %s',...
                    parName, signalName));
                s = surf(obj.dp, obj.dsn, reshape(search(i,:,:),...
                    length(obj.dsn), length(obj.dp)),...
                    'FaceAlpha', 0.9);
                s.EdgeColor = 'none';
                xlabel('Погрешность обнаружения %');
                ylabel('Соотношение сигнал/шум d_{с/ш}, дБ');
                zlabel(sprintf(...
                    'Исследуемый параметр %s',...
                    parName));
%                 xlim([min(obj.dp) max(obj.dp)]);
%                 ylim([min(obj.dsn) max(obj.dsn)]);
%                 zlim([0 max(reshape(search(i,:,:),...
%                     length(obj.dsn), length(obj.dp)), [], 'all')]);
            end
        end
    end
end

