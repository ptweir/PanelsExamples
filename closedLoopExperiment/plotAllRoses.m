figure
number_of_flies = size(mean_angle_all,1);
number_of_heights = size(mean_angle_all,2);
cmap = colormap;
colors = cmap(1:floor(size(cmap,1)/number_of_heights):end,:);
phi = 0:pi/50:2*pi;
circle_x = cos(phi);
circle_y = sin(phi);
for fly_num = 1:number_of_flies
    %subplot(ceil(sqrt(number_of_flies))+1,ceil(sqrt(number_of_flies)),fly_num)
    %patch('xdata',circle_x,'ydata',circle_y, 'facecolor','w','edgecolor','w');
    %hold on
    for height_index = 1:number_of_heights
        subplot(4,5,height_index)
        hold on
        theta = mean_angle_all(fly_num,height_index)+pi/2;
        radius = 1 - var_angle_all(fly_num,height_index);
        %ax = 3*radius*cos(theta);
        %ay = 3*radius*sin(theta);
        %plot([0 ax],[0 ay],'Color',colors(height_index,:),'LineWidth',2)
        %rose(all_data{height_index},'Color',colors(height_index,:))
        %xlim([-1 1]); ylim([-1 1]);
        plot(all_data_all(fly_num){height_index})
        %axis image
        axis off
    end
end
%make colorbar
subplot(ceil(sqrt(number_of_flies))+1,ceil(sqrt(number_of_flies)),ceil(sqrt(number_of_flies))^2+1:(ceil(sqrt(number_of_flies))+1)*ceil(sqrt(number_of_flies)))
hold on
for height_index = 1:number_of_heights
    plot([0 stimulus_height(height_index)],height_index*[1 1],'Color',colors(height_index,:),'LineWidth',2)
end
axis off
axis tight
set(gcf,'Color',[1 1 1])
