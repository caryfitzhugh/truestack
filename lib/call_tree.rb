class CallTree
  def initialize(methods)
    flat_methods = []
    # methods are { :method_name => [{ tstart, tend }, {tstart, tend} ]
    methods.each_pair do |k,v|
      flat_methods += v.map do |vv|
          vv = vv.merge(:name=>k).symbolize_keys
          vv[:tstart] = vv[:tstart].to_i
          vv[:tend]   = vv[:tend].to_i
          vv
      end
    end

    # Flat methods are [ method_name, { tstart, tend } ]
    sorted_flat_methods = flat_methods.sort_by {|m| [m[:tstart], -1 * m[:tend]] }

    # Set the tstart/end correctly on the top-level
    tstart = sorted_flat_methods.first[:tstart]
    tend   = sorted_flat_methods.last[:tend]

    @tree = create_tree(nil, sorted_flat_methods)
    @tree[:tstart] = tstart
    @tree[:tend]   = tend
  end

  def find_method(name, tstart, tend)
    ::Rails.logger.info("Find method: #{name} #{tstart} #{tend} #{@tree.to_yaml}")
    find_node_r(@tree, name, tstart.to_i, tend.to_i)
  end

  def for_each(&block)
    for_each_r(@tree, &block)
  end
  def root
    @tree
  end

  def to_hash
    @tree || {}
  end

  private

  def find_node_r(root, name, tstart, tend)
    if (root[:name] == name && root[:tstart] == tstart && root[:tend] == tend)
      return root
    # should we look more here? Is tstart within the root start / end?
    elsif root[:tstart] <= tstart && root[:tend] >= tend
      return root[:calls].find {|new_root| find_node_r(new_root, name, tstart, tend)}
    else
      nil
    end
  end

  def for_each_r(root, &block)
    block.call root
    root[:calls].each do |other_root|
      for_each_r(other_root, &block)
    end
  end

  def create_tree(parent, stack, path = [])
    if (parent.nil?)
      top  = stack.shift
      path << top[:name]
      parent = top.merge({:duration => 0, :calls => [], :path => path.join('.')})
    end

    if stack.first && parent[:tend] > stack.first[:tstart]
      top = stack.shift
      path << top[:name]
      top = top.merge({:duration => 0, :calls => [] , :path => path.join(".")})

      parent[:calls] << create_tree(top, stack, path.clone)
      create_tree(parent, stack, path.clone)
    else stack.first.nil?
      parent[:duration] = calc_duration(parent)
      return parent
    end
  end

  def calc_duration(node)
    return node[:tend] - node[:tstart] - node[:calls].map {|c| c[:duration] || 0 }.sum
  end
end
