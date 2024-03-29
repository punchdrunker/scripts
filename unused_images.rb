=begin
   Objective-Cなプログラム中で参照されていない画像ファイルを検出するスクリプト
   usage:
     ruby unused_images.rb [image_dir] [source_code_dir]
=end

def files_in_dir(item, images = [])
  if FileTest.directory?(item) then
    Dir.foreach( item ) do |file|
      next if /^\.{1,2}$/ =~ file
      files_in_dir( item.sub(/\/+$/,"") + "/" + file, images)
    end
  else
    images.push(item)
  end
  return images
end

def find_image(file, image)
  if (/\.m/ =~ File.basename(file) || /\.xib/ =~ File.basename(file))
    keyword = File.basename(image, '.*')
  else
    return []
  end
  keyword.sub!('@2x', '')

  result = open(file).grep(/#{keyword}/)
  return result
end

unless ARGV.length==2
  abort 'usage: ruby unused_images.rb [image_dir] [source_code_dir]'
end

image_dir = ARGV[0]
source_dir = ARGV[1]

sources = files_in_dir(source_dir)
images = files_in_dir(image_dir)

images.each do |image|
  count = 0
  sources.each do|source|
    result = find_image(source, image)
    count += result.length
  end
  puts image + "\n" if count==0
end
