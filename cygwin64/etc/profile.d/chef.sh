
_chef_ruby="/cygdrive/c/opscode/chefdk/embedded/bin/ruby"
_chef_bin_dir_win="C:/opscode/chefdk/bin"
for word in knife chef-client chef-solo shef; do
  alias $word="${_chef_ruby} ${_chef_bin_dir_win}/${word}"
done

