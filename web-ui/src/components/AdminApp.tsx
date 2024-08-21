import {Admin, Resource, ListGuesser, EditGuesser, List, Datagrid, TextField} from "react-admin";
import {adminDataProvider} from "@/components/AdminDataProvider";



const AdminApp = () => (
    <Admin dataProvider={adminDataProvider}>
        <Resource name='logs' list={LogsList} />
    </Admin>
);

const LogsList = () => {
        // timestamp,2,protocol,4,5,6,from,to,9,action
        return <List>
            <Datagrid>
                {/*<TextField source='id' />*/}
                <TextField source='timestamp'/>
                <TextField source='2'/>
                <TextField source='protocol'/>
                <TextField source='4'/>
                <TextField source='5'/>
                <TextField source='6'/>
                <TextField source='from'/>
                <TextField source='to'/>
                <TextField source='9'/>
                <TextField source='action'/>
            </Datagrid>
        </List>
}

export default AdminApp;