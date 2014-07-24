
_chef_ruby="/cygdrive/c/opscode/chef/embedded/bin/ruby"
_chef_bin_dir_win="C:/opscode/chef/bin"
for word in knife chef-client chef-solo shef; do
  alias $word="${_chef_ruby} ${_chef_bin_dir_win}/${word}"
done

