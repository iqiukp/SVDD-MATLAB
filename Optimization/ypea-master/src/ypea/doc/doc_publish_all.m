% Publishes all documents

clc;
clear;
close all;

options.format = 'html';
options.createThumbnail = true;

files = dir('doc_*.m');
for i = 1:numel(files)
    filename = files(i).name;
    disp("Publishing " + filename + " ...");
    publish(filename, options);
    disp(' ');
    close all;
end
