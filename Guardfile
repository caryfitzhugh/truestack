# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spinach' do
  watch(%r|^features/(.*)\.feature|)
  watch(%r|^features/steps/(.*)([^/]+)\.rb|) do |m|
    "features/#{m[1]}#{m[2]}.feature"
  end
end
