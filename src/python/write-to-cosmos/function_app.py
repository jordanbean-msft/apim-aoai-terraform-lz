import azure.functions as func
import datetime
import json
import logging

app = func.FunctionApp()

@app.function_name(name="write-to-cosmos")
@app.event_hub_message_trigger(arg_name="azeventhub", 
                               event_hub_name="central-llm-logging",
                               consumer_group="write-to-cosmos",
                               connection="EVENT_HUB")
@app.cosmos_db_output(arg_name="outputDocument", 
                      database_name="chat-log-db", 
                      container_name="chat-log-container", 
                      connection_string_setting="COSMOS_DB")
def eventhub_trigger(azeventhub: func.EventHubEvent, 
                     outputDocument: func.Out[func.Document]) -> str:
    logging.info('Python EventHub trigger processed an event: %s',
                azeventhub.get_body().decode('utf-8'))
    req_body = azeventhub.get_body().decode('utf-8')
    outputDocument.set(req_body)
    return 'OK'
