class Thing < ActiveRecord::Base
  class Create < Trailblazer::Operation
    include Model
    model Thing, :create

    contract Contract::Create

    def process(params)
      validate(params[:thing]) do |f|
        f.save

        reset_authorships!
      end
    end

  private
    def reset_authorships!
      model.authorships.each { |authorship| authorship.update_attribute(:confirmed, 0) }
    end
  end

  class Update < Create
    action :update

    contract Contract::Update
  end
end

# (fragment:, collection:, index:, **) {
#             user = users.find { |u| u.id.to_s == fragment["id"].to_s }

#             if fragment["remove"].to_s == "1" and users.delete(user)
#               return Representable::Pipeline::Stop
#             end

#             return Representable::Pipeline::Stop if collection[index] # populate-if_empty

#             users.insert(index, User.new)