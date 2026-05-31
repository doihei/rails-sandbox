module Sources
  class RecordById < GraphQL::Dataloader::Source
    def initialize(model)
      @model = model
    end

    def fetch(ids)
      records = @model.where(id: ids).index_by { |r| r.id }
      ids.map { |id| records[id] }
    end
  end
end
