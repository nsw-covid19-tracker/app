# Deploy function for fetching data
gcloud functions deploy fetch-data \
    --entry-point main \
    --runtime python37 \
    --trigger-resource fetch-data \
    --trigger-event google.pubsub.topic.publish \
    --ingress-settings internal-only \
    --memory 128MB \
    --timeout 180s

# Schedule data fetch
gcloud scheduler jobs create pubsub daily_scrape \
    --schedule "0 6,12,18 * * *" \
    --time-zone "Australia/Sydney" \
    --topic fetch-data \
    --message-body "Fetch NSW COVID-19 Case Locations"
