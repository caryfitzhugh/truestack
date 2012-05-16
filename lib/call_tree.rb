class CallTree
  def initialize(start_method, methods)
    flat_methods = []
    # methods are { :method_name => [{ tstart, tend }, {tstart, tend} ]
    methods.each_pair {|k,v| flat_methods += v.map {|vv| vv.merge(:name=>k).symbolize_keys} }
    # Flat methods are [ method_name, { tstart, tend } ]
    sorted_flat_methods = flat_methods.sort_by {|m| [m[:tstart], -1 * m[:tend]] }

    # Set the tstart/end correctly on the top-level
    tstart = sorted_flat_methods.first[:tstart]
    tend   = sorted_flat_methods.last[:tend]

    @tree = create_tree(nil, sorted_flat_methods)
    @tree[:tstart] = tstart
    @tree[:tend]   = tend
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
