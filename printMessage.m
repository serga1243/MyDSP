function printMessage(type, time, data, ct)
switch type
    case 1
        fprintf('Вычисление вероятности правильного обнаружения началось ');
        if time == false
            return;
        elseif time == true
        clock = char([55357     56667;
                    55357       56656;
                    55357       56657;
                    55357       56658;
                    55357       56659;
                    55357       56660;
                    55357       56661;
                    55357       56662;
                    55357       56663;
                    55357       56664;
                    55357       56665;
                    55357       56666]);
            fprintf('%c', clock(data,:));
            fprintf('\n');
        end
    case 2
        clc;
        printMessage(1, true, ct);
        d1 = data(2)*data(3)*data(4);
        d2 = d1-data(1);
        r = 40;
        t = round(r*data(1)/d1);
        fprintf('\tпрошло:\t  %s c\n', duration(0, 0, time*data(1)));
        fprintf('\t');
        fprintf('%c', repmat(char(9632), 1, t));
        fprintf('%c', repmat(char(9744), 1, r-t));
        fprintf('\n');
        fprintf('\tосталось: %s c\n', duration(0, 0, time*d2));
    case 3
        fprintf('Вычисление вероятности правильного обнаружения закончилось\n');
    case 4
        fprintf('Построение графиков сигнала %s с параметром %s\n',...
            time, data);
end
end
