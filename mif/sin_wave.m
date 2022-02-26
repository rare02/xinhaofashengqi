F1=1;                   %�ź�Ƶ��
Fs=2^9;                %����Ƶ��
P1=0;                   %�źų�ʼ��λ
N=2^9;                 %��������
t=[0:1/Fs:(N-1)/Fs];    %����ʱ��
ADC=2^7 - 1;            %ֱ������
A=2^7;                  %�źŷ���
%���������ź�
s=A*sin(2*pi*F1*t + pi*P1/180) + ADC;
plot(s);                %����ͼ��
%����mif�ļ�
fild = fopen('sin_wave_512x8.mif','wt');
%д��mif�ļ�ͷ
fprintf(fild, '%s\n','WIDTH=8;');           %λ��
fprintf(fild, '%s\n\n','DEPTH=512;');      %���
fprintf(fild, '%s\n','ADDRESS_RADIX=UNS;'); %��ַ��ʽ
fprintf(fild, '%s\n\n','DATA_RADIX=UNS;');  %���ݸ�ʽ
fprintf(fild, '%s\t','CONTENT');            %��ַ
fprintf(fild, '%s\n','BEGIN');              %��ʼ
for i = 1:N
    s2(i) = round(s(i));    %��С������������ȡ��
    if s2(i) <0             %��1ǿ������
        s2(i) = 0
    end
    fprintf(fild, '\t%g\t',i-1);    %��ַ����
    fprintf(fild, '%s\t',':');      %ð��
    fprintf(fild, '%d',s2(i));      %����д��
    fprintf(fild, '%s\n',';');      %�ֺţ�����
end
fprintf(fild, '%s\n','END;');       %����
fclose(fild);