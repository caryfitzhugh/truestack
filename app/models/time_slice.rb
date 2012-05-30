# @CMS = Count. Mean. StdDev
# Our document looks like:
# _ID = #{APP_ID}_#{SLICE_ID}_#{TIMESTAMP}
# { ** timings_stuff
#   deploys => {
#     deploy_hash => {
#       _browser: {
#         @CMS - all browser readies
#         controller#action { @ CMS }
#       },
#       _requests: {
#         method#name : {
#           @CMS - this request
#           _exceptions: [exception_name:backtrace_[0]_line]
#           called_method#name => { .. recursive .. }
#           called_method#name2 => { .. }
#         }
#       },
#       _methods: {
#         klass#action => {
#           @CMS - this_method
#           _exceptions => []
#           _requests => {
#             controller#action { @CMS }
#           }
#         }
#       },
#       _exceptions: {
#         name#line_no => [timestamp]
#       }
#     }
#     other_deploy_hash => {
#     },
#   },
module TimeSlice
  module SliceManipulationMethods

    def find_slices(user_app, since_time)
      time_end   = Time.now
      time_start = time_end - since_time

      self.where(
        :_id.gte => self.slice_id(   time_start, user_app.id),
        :_id.lte => self.slice_id(time_end,   user_app.id))
    end


    def mongo_path(*args)
      array = [args].flatten
      array.map {|v| v.gsub(".", "_") }.join(".")
    end
    def add_exception_to_slice(deploy_key, id, req_name, exception_name, failed_in_method, failed_path, tstart, backtrace, env)
      exception_id = mongo_path("#{exception_name}@#{backtrace.first}")

      # Update the exception list
      collection.update( { '_id' =>  id },
        {
          '$push' =>  {
            # Add to exception timing
            mongo_path(deploy_key,'_exceptions', exception_id, '_times') => tstart
          },
          '$addToSet' => {
            # The request
            # Update in the request map
            mongo_path(deploy_key,"_requests",req_name,"_exceptions") =>  exception_id,
            # Update in the call tree.  "Where it was called"
            mongo_path(deploy_key,"_requests",req_name, failed_path.split('.'),"_exceptions") =>  exception_id,
            # Update in the method map (so you can see # of exceptions in a method)
            mongo_path(deploy_key,"_methods",failed_in_method,"_exceptions") =>  exception_id,
           },
           '$set'  =>  {
            # Add exception details
            mongo_path(deploy_key,"_exceptions",exception_id,"_backtrace") =>  backtrace.to_json,
            mongo_path(deploy_key,"_exceptions",exception_id,"_env")       =>  env.to_json
           }
        },
        :upsert =>  true,
        :safe =>  true
      )

    end

    def add_browser_ready_timing_to_slice(deploy_key, id, request_method_name, tstart, duration)
      method_name = "browser#ready"

      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key,'_browser'), duration)

      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key,'_browser',request_method_name), duration)

      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key,"_browser",request_method_name, method_name), duration)

      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key,"_methods", method_name), duration)

      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key,"_methods", method_name, "_requests", request_method_name), duration)
    end

    def add_request_to_slice(deploy_key, id, req_name, tree)
      # Top-deploy level
      MongoRaw.eval('update_timings', self.collection_name, id,
        mongo_path(deploy_key, "_requests"), tree.root[:duration])

      # Deploy level
      path = [deploy_key];
      tree.for_each do |node|
        # For each of the actions , traverse the tree and then call update_timings on them.

        # deploy_key.mylist#show. {  Mylist#before_filter1, Mylist#show, Mylist#after_filter1 .... }
        MongoRaw.eval('update_timings', self.collection_name, id,
          mongo_path(deploy_key,"_requests", req_name, node[:path].split('.')), node[:duration])

        # Do this just for the individual methods
        # This rolls them up so that we get an overall timing for each method in the slice
        # Method detail page!
        MongoRaw.eval('update_timings', self.collection_name, id,
          mongo_path(deploy_key,"_methods",node[:name]), node[:duration])

        # Rollup by request calling this method
        MongoRaw.eval('update_timings', self.collection_name, id,
          mongo_path(deploy_key,"_methods",node[:name], "_requests", req_name), node[:duration])
      end
    end

    def slice_id(start, app_id)
      start = TruestackClient.to_timestamp(start)
      # Convert to MS
      timestamp = (start / (self::SLICE_WINDOW * 1000)).to_i * 1000 * self::SLICE_WINDOW

      mongo_path("#{app_id}-#{timestamp}")
    end
  end

  class Day
    SLICE_WINDOW = 60 * 60 * 24
    include Mongoid::Document
    extend SliceManipulationMethods
    belongs_to :user_application
  end

  class Hour
    SLICE_WINDOW = 60 * 60
    include Mongoid::Document
    extend SliceManipulationMethods
    belongs_to :user_application
  end

  def self.decode_window_size(param)
    # e.g.  [ TimeSlice::Day, 21.days]
    [TimeSlice::Hour, 1.day]
  end

  def self.add_request(app_id, deploy_key, method_name, actions)
    # Convert array of methods to tree, start with the root!
    # Actions are:
    #   {
    #     method#name => [
    #       { tstart: , tend:}
    #     ]
    #   }

    # Tree is
    #   { :name, :tstart, :tend, :duration, :calls => [] }
    tree = CallTree.new(actions)

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|
      id = slice_klass.slice_id(tree.root[:tstart], app_id)

      slice_klass.add_request_to_slice(deploy_key, id, method_name, tree)
    end

  end

  def self.add_browser_ready_timing(app_id, deploy_key, request_method_name, tstart, duration)

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|

      id = slice_klass.slice_id(tstart, app_id)

      slice_klass.add_browser_ready_timing_to_slice(deploy_key, id, request_method_name, tstart, duration)
    end
  end

  def self.add_exception(app_id, deploy_key, req_name, exception_name, failed_in_method, actions, tstart, backtrace, env)
    # Look up the last timing for the given failed in method.
    # That is the 'instance' which has an exception
    # Add the request, with this extra data.

    tree = CallTree.new(actions)

    failed_in = actions[failed_in_method].last.symbolize_keys

    failed_method = tree.find_method(failed_in_method, failed_in[:tstart], failed_in[:tend])
    failed_path = failed_method[:path] + ".#{failed_in_method}"

    [TimeSlice::Day, TimeSlice::Hour].each do |slice_klass|

      id = slice_klass.slice_id(tstart, app_id)

      slice_klass.add_exception_to_slice(deploy_key, id, req_name, exception_name, failed_in_method,
                                         failed_path, tstart, backtrace, env)
    end
  end
end
