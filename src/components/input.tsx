import { Button, HStack, Input, Text, VStack } from '@chakra-ui/react'
import React from 'react'
import { OpenAIClient , ddlModelSample} from '../dsl-generator/openai'
import { SchemaGenerator } from "../dsl-parser/schema_generator";

function TextInput() {
    const [value, setValue] = React.useState('')
    const [result, setResult] = React.useState({model:'', payload:''})
    const [isLoading, setIsLoading] = React.useState(false)
    const openAIClient = new OpenAIClient()

    const handleSubmit = React.useCallback( async (e) => {
        e.preventDefault();
        setIsLoading(true);
        const generated_model = await openAIClient.createCompletion(ddlModelSample, value);
        const parsed_model = SchemaGenerator.parse(generated_model);
        setIsLoading(false);
        setResult({
            model : generated_model,
            payload : JSON.stringify(parsed_model, null, 2)
        })
    },[value, isLoading, result])

    return (
        <>
            <Text mb='8px' fontSize='xl'>{"What kind of application would you like to create?"}</Text>
            <HStack>
                <Input
                    value={value}
                    onChange={(e) => {
                        setValue(e.target.value)
                    }}
                    placeholder='Describe your app!'
                    pr='4.5rem'
                />
                <Button
                    isLoading={isLoading}
                    loadingText='Submitting'
                    colorScheme='blue'
                    variant='outline'
                    onClick={handleSubmit}
                >
                    Submit
                </Button>
            </HStack>
            <HStack alignItems={'start'} mt={'25px'}>
                <VStack width={'50%'}>
                    <Text fontSize='xl' as='b'>Model</Text>
                    <Text>(GPT 3 generated DSL for application database schema)</Text>
                    <pre className={'code'}>{result.model}</pre>
                </VStack>
                <VStack width={'50%'}>
                    <Text fontSize='xl' as='b'>Qore Data Payload</Text>
                    <Text>(DSL Parse Result)</Text>
                    <pre className={'code'}>{result.payload}</pre>
                </VStack>
            </HStack>
        </>
    )
  }
  
  export default TextInput