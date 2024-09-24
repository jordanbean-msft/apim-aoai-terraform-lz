import azure.functions as func
import datetime
import json
import logging
from collections import deque
from itertools import repeat

app = func.FunctionApp()

@app.function_name(name="write-to-cosmos")
@app.event_hub_message_trigger(arg_name="azeventhub", event_hub_name="llm-logging", consumer_group="write-to-cosmos", connection="EVENT_HUB")
@app.cosmos_db_output(arg_name="outputDocument", database_name="chat-log-db", container_name="chat-log-container", connection="COSMOS_DB")
def write_to_cosmos(azeventhub: func.EventHubEvent, outputDocument: func.Out[func.Document]):
    req_body = azeventhub.get_body().decode('utf-8')
    outputDocument.set(func.Document.from_json(req_body))

@app.function_name(name="replication-siem-logging")
@app.event_hub_message_trigger(arg_name="azeventhub", event_hub_name="central-llm-logging", consumer_group="central-siem-replication", connection="EVENT_HUB")
@app.event_hub_output(arg_name="event", event_hub_name="siem-logging", connection="EVENT_HUB")
def replicate_siem_event(azeventhub: func.EventHubEvent, event: func.Out[str]):
    body = azeventhub.get_body()
    if body is not None:
        event.set(body.decode('utf-8'))

siem_keys_to_remove = ['email', 'ipaddr', 'unique_name', 'name']

@app.function_name(name="replication-llm-logging")
@app.event_hub_message_trigger(arg_name="azeventhub", event_hub_name="central-llm-logging", consumer_group="central-llm-replication", connection="EVENT_HUB")
@app.event_hub_output(arg_name="event", event_hub_name="llm-logging", connection="EVENT_HUB")
def replicate_llm_event(azeventhub: func.EventHubEvent, event: func.Out[str]):
    body = azeventhub.get_body()
    if body is not None:
        jsonBody = json.loads(body.decode('utf-8'))
        # remove keys the the SIEM needs but not the LLM logging from the dictionary
        deque(map(jsonBody.pop, siem_keys_to_remove, repeat(None)), 0)
        event.set(json.dumps(jsonBody))