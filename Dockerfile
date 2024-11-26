FROM innovanon/ia_pause AS pause
FROM innovanon/ia_setup AS setup

COPY --from=pause /tmp/py/ /tmp/py/
RUN pip install --no-cache-dir --upgrade -r requirements.txt
RUN pip install --no-cache-dir --upgrade .
RUN rm -rf /tmp/py/

COPY ./ ./
RUN pip install --no-cache-dir --upgrade -r requirements.txt
RUN pip install --no-cache-dir --upgrade .
ENTRYPOINT ["python", "-m", "ia_shit"]
