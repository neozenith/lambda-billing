'use strict';

exports.event_handler = function (event, context, callback) {
  for (var ek in event){
    console.log('event[' + ek + ']: ' + event[ek]);
  }

  for (var ck in context){
    console.log('context[' + ck + ']: ' + context[ck]);
  }
};
