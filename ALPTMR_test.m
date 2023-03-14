
file_dir = './data/AR120p20s50by40.mat';
data_mat = load(file_dir).AR120p20s50by40;


class_nums = 120;
num = 20;
train_nums = 10;
labeled_nums = 3;
max_iter = 10;  %最大迭代次数
k = 30;  %k近邻参数 
k_pca = 300;  
alpha = 0.8;  %正则项系数
beta = 0.1; %L21正则项系数
gamma =0;%capped正则项系数
epsilon = 1e9;
repeatN = 10; %重复实验次数


[heigth, width, ~] = size(data_mat);

%data_mat = func_digahole(data_mat, 10);
[X_train, X_test, Y_train, Y_test] = get_X_and_labels(data_mat, class_nums, ...
        num, train_nums, width, heigth);
%size(X_train)==d*N
%size(Y_train)==c*N

%X_train = normalize(X_train, 2);

%impose PCA on original data
P_pca = PCA(X_train, k_pca);
X_train = P_pca'*X_train;
X_test = P_pca'*X_test;

%
[X, XL, XU, Y, YL, YU, YU_label] = get_L_and_U(X_train, Y_train, ...
    train_nums, labeled_nums, class_nums);
%size(XL)==labeled_nums*class_nums
%size(XU)==(num-labeled_nums)*class_nums 

alpha = 10;
beta = 10;
gamma = 1e3;
YU_0 = zeros(class_nums, class_nums*(num-labeled_nums));

[F, W] = func_ALPTMR(XL, [XU, X_train], YL, YU_0, alpha, beta, gamma);

%predict
Y_predict = F(:, class_nums*labeled_nums+1:size(F, 2));
mid_Y = zeros(size(Y_predict));
[~, c_index] = max(Y_predict);
for i =1:size(X_test, 2)
    mid_Y(c_index(i), i)=1;
end
Y_predict = mid_Y;
  
%compute accuracy
Y_test = [YU_label, Y_test];
acc_num = 0;
for n = 1:size(Y_predict, 2)
    if Y_predict(:, n) == Y_test(:, n)
        acc_num = acc_num + 1;
    end
end
acc_rate = acc_num/size(Y_predict, 2)

