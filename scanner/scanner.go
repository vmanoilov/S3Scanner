package scanner

import (
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"
)

// ScanResult represents the result of scanning a single bucket
type ScanResult struct {
	BucketName   string
	IsPublic     bool
	Permissions  string
	Error        string
	ResponseTime int64
}

// Scanner handles S3 bucket scanning operations
type Scanner struct {
	client     *http.Client
	results    []ScanResult
	mutex      sync.Mutex
	UserAgent  string
	TimeoutSec int
}

// NewScanner creates a new Scanner instance
func NewScanner() *Scanner {
	return &Scanner{
		client: &http.Client{
			Timeout: time.Second * 10,
		},
		UserAgent:  "S3Scanner/1.0",
		TimeoutSec: 10,
		results:    make([]ScanResult, 0),
	}
}

// ScanBucket checks if a single bucket is publicly accessible
func (s *Scanner) ScanBucket(bucketName string) *ScanResult {
	startTime := time.Now()
	result := &ScanResult{
		BucketName: bucketName,
	}

	// Generate URLs for different regions
	urls := []string{
		fmt.Sprintf("https://%s.s3.amazonaws.com", bucketName),
		fmt.Sprintf("https://s3.amazonaws.com/%s", bucketName),
	}

	for _, url := range urls {
		req, err := http.NewRequest("GET", url, nil)
		if err != nil {
			result.Error = fmt.Sprintf("Error creating request: %v", err)
			continue
		}

		req.Header.Set("User-Agent", s.UserAgent)

		resp, err := s.client.Do(req)
		if err != nil {
			result.Error = fmt.Sprintf("Error making request: %v", err)
			continue
		}
		defer resp.Body.Close()

		// Check response status
		switch resp.StatusCode {
		case 200:
			result.IsPublic = true
			result.Permissions = "Read"
		case 403:
			result.IsPublic = false
			result.Permissions = "Forbidden"
		case 404:
			result.IsPublic = false
			result.Permissions = "Not Found"
		default:
			result.IsPublic = false
			result.Permissions = fmt.Sprintf("Unknown (%d)", resp.StatusCode)
		}

		// If we found a valid response, break the loop
		if result.Error == "" {
			break
		}
	}

	result.ResponseTime = time.Since(startTime).Milliseconds()
	return result
}

// ScanBuckets scans multiple buckets concurrently
func (s *Scanner) ScanBuckets(bucketNames []string) []ScanResult {
	var wg sync.WaitGroup
	results := make([]ScanResult, 0)
	semaphore := make(chan struct{}, 20) // Limit concurrent requests

	for _, bucket := range bucketNames {
		wg.Add(1)
		go func(bucketName string) {
			defer wg.Done()
			semaphore <- struct{}{} // Acquire
			defer func() { <-semaphore }() // Release

			result := s.ScanBucket(bucketName)
			s.mutex.Lock()
			results = append(results, *result)
			s.mutex.Unlock()
		}(bucket)
	}

	wg.Wait()
	return results
}

// GetFormattedResults returns scan results in a formatted string
func (s *Scanner) GetFormattedResults(results []ScanResult) string {
	var builder strings.Builder
	for _, result := range results {
		status := "Private"
		if result.IsPublic {
			status = "Public"
		}
		
		builder.WriteString(fmt.Sprintf("Bucket: %s\n", result.BucketName))
		builder.WriteString(fmt.Sprintf("Status: %s\n", status))
		builder.WriteString(fmt.Sprintf("Permissions: %s\n", result.Permissions))
		if result.Error != "" {
			builder.WriteString(fmt.Sprintf("Error: %s\n", result.Error))
		}
		builder.WriteString(fmt.Sprintf("Response Time: %dms\n", result.ResponseTime))
		builder.WriteString("-------------------\n")
	}
	return builder.String()
}
