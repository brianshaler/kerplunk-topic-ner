_ = require 'lodash'
Promise = require 'when'
request = require 'request'

module.exports = (System) ->
  Topic = System.getModel 'Topic'

  {ip, ports} = System.getService 'ner'
  url = "http://#{ip}:#{ports['8008/tcp']}/ner"

  addTopics = (item) ->
    if item.attributes?.ner
      return item
    unless item.message?.length > 0
      return item

    Promise.promise (resolve, reject) ->
      opt =
        url: url
        method: 'POST'
        # headers:
        #   'ContentType': 'application/json'
        json: true
        body:
          file: item.message

      request opt, (err, httpResponse, body) ->
        topics = []
        if body?.entities
          for type, entities of body.entities
            for entity in entities
              topics.push "#{type}:#{entity.toLowerCase()}"
        return resolve item unless topics.length > 0
        Topic.getOrCreateArray topics
        .then (topics) ->
          item.attributes = {} unless item.attributes
          item.attributes.ner = true
          item.attributes.topic = [] unless item.attributes.topic
          item.attributes.topic = _ item.attributes.topic.concat topics
            .map (topic) ->
              String topic._id ? topic
            .uniq()
            .value()
        .done ->
          resolve item
        , (err) ->
          resolve item

  events:
    activityItem:
      save:
        pre: addTopics
