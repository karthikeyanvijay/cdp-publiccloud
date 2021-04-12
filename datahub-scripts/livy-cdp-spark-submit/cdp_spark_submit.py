#!/usr/bin/env python3
import json
import logging
import time

import requests
from requests.auth import HTTPBasicAuth


def parse_job_conf(job_conf_file):
    logging.info("Parsing job config file: ")
    with open(job_conf_file) as f:
        file_content = json.load(f)
    return file_content


def cdp_spark_submit():
    response = submit_job()
    track_job(response)


def submit_job():
    response = requests.post(
        url + "/batches",
        data=json.dumps(data),
        headers={"Content-Type": "application/json"},
        auth=HTTPBasicAuth(username, password),
    )
    logging.info("Spark submit response: ")
    logging.info(response.json())
    logging.info("Header: ")
    logging.info(response.headers)
    return response.headers


def track_job(response_headers):
    job_status = ""
    session_url = url + response_headers["Location"].split("/statements", 1)[0]
    logging.info(session_url)
    while job_status != "success":
        statement_url = url + response_headers["Location"]
        statement_response = requests.get(
            statement_url,
            headers={"Content-Type": "application/json"},
            auth=HTTPBasicAuth(username, password),
        )
        job_status = statement_response.json()["state"]
        logging.info("Job status : " + job_status)

        lines = requests.get(
            session_url + "/log",
            headers={"Content-Type": "application/json"},
            auth=HTTPBasicAuth(username, password),
        ).json()["log"]

        for line in lines:
            logging.info(line)

        if job_status == "dead":
            raise ValueError(
                "Job Failed: " + job_status
            )

        if "progress" in statement_response.json():
            logging.info("Progress: " + str(statement_response.json()["progress"]))
        time.sleep(10)


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
    )
    url = "https://datahub1-manager0.ps-sandb.a465-9q4k.cloudera.site/datahub1/cdp-proxy-api/livy/"
    username = "vkarthikeyan"
    password = "WorkloadPassWord"
    data = parse_job_conf("./jobconf.json")
    cdp_spark_submit()