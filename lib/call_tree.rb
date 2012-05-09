class CallTree
  def initialize(start_method, methods)
    flat_methods = []
    # methods are { :method_name => [{ tstart, tend }, {tstart, tend} ]
    methods.each_pair {|k,v| flat_methods += v.map {|vv| vv.merge(:name=>k)} }
    # Flat methods are [ method_name, { tstart, tend } ]
    sorted_flat_methods = flat_methods.sort_by {|m| [m[:tstart], -1*m[:tend]] }
    @tree = create_tree(nil, sorted_flat_methods)
  end

  def to_hash
    @tree || {}
  end

  private

  def create_tree(parent, stack)
    if (parent.nil?)
      top  = stack.shift
      parent = top.merge({:duration => 0, :calls => [] })
    end

    if stack.first && parent[:tend] > stack.first[:tstart]
      top = stack.shift
      top = top.merge({:duration => 0, :calls => [] })
      parent[:calls] << create_tree(top, stack)
      create_tree(parent, stack)
    else stack.first.nil?
      parent[:duration] = calc_duration(parent)
      return parent
    end
  end

  def calc_duration(node)
    return node[:tend] - node[:tstart] - node[:calls].map {|c| c[:duration] || 0 }.sum
  end
end
